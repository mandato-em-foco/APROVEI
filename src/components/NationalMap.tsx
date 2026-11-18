import { useEffect, useMemo, useState } from "react";
import { supabase } from "../lib/supabase";
import { MapPin, ChevronRight, ExternalLink, ShieldCheck, Search, X } from "lucide-react";

type Contest = {
  id: string; title: string; sphere: string; employment_type: string; source_url: string | null; state: string | null; city: string | null;
  level: string | null; status: string; deadline: string | null;
  official_url: string | null; registration_url: string | null;
  vacancies: number | null; salary_min: number | null; salary_max: number | null;
};
type Authorization = {
  id: string; title: string; state: string | null; city: string | null;
  agency: string; positions: string | null; vacancies: number | null;
  salary_min: number | null; salary_max: number | null; status: string;
  source_url: string | null; authorized_at: string | null; notes: string | null;
};
type Feature = { type: string; properties: { name: string; abbreviation: string }; geometry: any };
type FeatureCollection = { features: Feature[] };
const GEO_URL = "https://raw.githubusercontent.com/codeforgermany/click_that_hood/48ba05ad4c6969e3b3c25735492169227ae411f1/public/data/brazil-states.geojson";
const regions: Record<string, { label: string; color: string }> = {
  AC:{label:"Norte",color:"#2878a8"}, AP:{label:"Norte",color:"#2878a8"}, AM:{label:"Norte",color:"#2878a8"}, PA:{label:"Norte",color:"#2878a8"}, RO:{label:"Norte",color:"#2878a8"}, RR:{label:"Norte",color:"#2878a8"}, TO:{label:"Norte",color:"#2878a8"},
  AL:{label:"Nordeste",color:"#d58a27"}, BA:{label:"Nordeste",color:"#d58a27"}, CE:{label:"Nordeste",color:"#d58a27"}, MA:{label:"Nordeste",color:"#d58a27"}, PB:{label:"Nordeste",color:"#d58a27"}, PE:{label:"Nordeste",color:"#d58a27"}, PI:{label:"Nordeste",color:"#d58a27"}, RN:{label:"Nordeste",color:"#d58a27"}, SE:{label:"Nordeste",color:"#d58a27"},
  DF:{label:"Centro-Oeste",color:"#6e58ae"}, GO:{label:"Centro-Oeste",color:"#6e58ae"}, MT:{label:"Centro-Oeste",color:"#6e58ae"}, MS:{label:"Centro-Oeste",color:"#6e58ae"},
  ES:{label:"Sudeste",color:"#26977f"}, MG:{label:"Sudeste",color:"#26977f"}, RJ:{label:"Sudeste",color:"#26977f"}, SP:{label:"Sudeste",color:"#26977f"},
  PR:{label:"Sul",color:"#bd5571"}, RS:{label:"Sul",color:"#bd5571"}, SC:{label:"Sul",color:"#bd5571"}
};
const money = (v: number) => v.toLocaleString("pt-BR",{style:"currency",currency:"BRL",maximumFractionDigits:0});
function coordsToPath(coords: any, project: (p:number[])=>[number,number]): string {
  if (!Array.isArray(coords) || !coords.length) return "";
  if (typeof coords[0]?.[0] === "number") return coords.map((p:number[],i:number)=>{const [x,y]=project(p);return (i?"L":"M")+x.toFixed(1)+","+y.toFixed(1)}).join(" ")+" Z";
  return coords.map((part:any)=>coordsToPath(part,project)).join(" ");
}
function geometryPath(geometry:any,project:(p:number[])=>[number,number]) {
  if(!geometry) return "";
  return geometry.type==="Polygon" ? coordsToPath(geometry.coordinates,project) :
    geometry.type==="MultiPolygon" ? geometry.coordinates.map((poly:any)=>coordsToPath(poly,project)).join(" ") : "";
}
export default function NationalMap({ contests }: { contests: Contest[] }) {
  const [geo,setGeo]=useState<FeatureCollection|null>(null);
  const [geoError,setGeoError]=useState("");
  const [authorizations,setAuthorizations]=useState<Authorization[]>([]);
  const [selected,setSelected]=useState("");
  const [showAuthorized,setShowAuthorized]=useState(false);
  const [authSearch,setAuthSearch]=useState("");
  const [loading,setLoading]=useState(true);
  useEffect(()=>{fetch(GEO_URL).then(r=>{if(!r.ok)throw new Error("Não foi possível carregar o mapa.");return r.json()}).then(setGeo).catch(()=>setGeoError("O mapa geográfico não carregou. A lista por estado continua disponível."));},[]);
  useEffect(()=>{let alive=true;(async()=>{if(!supabase){setLoading(false);return;}const {data,error}=await supabase.from("contest_authorizations").select("*").order("authorized_at",{ascending:false});if(alive){if(!error&&data)setAuthorizations(data as Authorization[]);setLoading(false);}})();return()=>{alive=false}},[]);
  const stateFeatures=geo?.features||[];
  const selectedName=stateFeatures.find(f=>f.properties.abbreviation===selected)?.properties.name||selected;
  const stateContests=contests.filter(c=>selected?(c.state===selected||c.sphere==="federal"):true);
  const stateAuthorizations=authorizations.filter(a=>selected?(a.state===selected||a.sphere==="federal"):true);
  const averages=useMemo(()=>Object.keys(regions).map(uf=>{const rows=contests.filter(c=>c.state===uf&&c.employment_type!=="temporary"&&(c.salary_min||c.salary_max));const vals=rows.map(c=>((Number(c.salary_min)||Number(c.salary_max)||0)+(Number(c.salary_max)||Number(c.salary_min)||0))/2);return {uf,avg:vals.length?vals.reduce((s,v)=>s+v,0)/vals.length:0,count:rows.length}}),[contests]);
  const maxAverage=Math.max(1,...averages.map(x=>x.avg));
  const filteredAuthorizations=stateAuthorizations.filter(a=>[a.title,a.agency,a.positions||"",a.city||"",a.state||""].join(" ").toLowerCase().includes(authSearch.toLowerCase()));
  const project=(p:number[]):[number,number]=>[(p[0]+74)*14.5+15,(6-p[1])*14.2+12];
  const stateCount=stateFeatures.length||27;
  return <section className="national-contests">
    <div className="national-heading"><div><span className="eyebrow">PAINEL NACIONAL</span><h2>Concursos públicos em todo o Brasil</h2><p>Selecione uma unidade federativa para consultar editais publicados e oportunidades em andamento.</p></div><div className="national-total"><strong>{contests.length}</strong><span>editais cadastrados</span></div></div>
    <div className="national-layout">
      <section className="national-map-panel">
        <div className="national-panel-heading"><div><span className="eyebrow">MAPA INTERATIVO</span><h3>Selecione um estado</h3></div><button className="national-clear" onClick={()=>setSelected("")}>Ver Brasil <X size={14}/></button></div>
        <div className="national-map-wrap">
          {geo ? <svg className="brazil-svg" viewBox="0 0 610 590" role="img" aria-label="Mapa interativo dos estados brasileiros">
            {stateFeatures.map(feature=>{const uf=feature.properties.abbreviation;const active=selected===uf;return <path key={uf} d={geometryPath(feature.geometry,project)} fill={regions[uf]?.color||"#78909c"} className={active?"brazil-state selected":"brazil-state"} onClick={()=>setSelected(active?"":uf)} role="button" tabIndex={0} aria-label={feature.properties.name} onKeyDown={e=>{if(e.key==="Enter"||e.key===" "){e.preventDefault();setSelected(active?"":uf)}}}><title>{feature.properties.name}</title></path>})}
            {stateFeatures.map(f=>{const p=project(centroid(f.geometry));return <text key={f.properties.abbreviation} x={p[0]} y={p[1]} className="brazil-label" pointerEvents="none">{f.properties.abbreviation}</text>})}
          </svg> : <div className="national-map-loading">{geoError||"Carregando mapa do Brasil..."}</div>}
        </div>
        <div className="national-legend">{["Norte","Nordeste","Centro-Oeste","Sudeste","Sul"].map((r,i)=><span key={r}><i style={{background:["#2878a8","#d58a27","#6e58ae","#26977f","#bd5571"][i]}}/>{r}</span>)}</div>
        <p className="national-map-note">{stateCount} unidades federativas • Toque em um estado para filtrar as oportunidades.</p>
      </section>
      <button className="authorized-tile" onClick={()=>setShowAuthorized(v=>!v)} aria-expanded={showAuthorized}>
        <span className="authorized-icon"><ShieldCheck size={25}/></span><span className="eyebrow">ACOMPANHAMENTO</span><strong>Concursos autorizados</strong><span className="authorized-number">{authorizations.length}</span><small>Sem edital publicado • apenas informações da autorização</small><span className="authorized-open">{showAuthorized?"Fechar lista":"Abrir lista"} <ChevronRight size={17}/></span>
      </button>
    </div>
    <section className="salary-panel">
      <div className="national-panel-heading"><div><span className="eyebrow">INDICADOR DE REMUNERAÇÃO</span><h3>Média salarial por estado</h3></div><small>Altura proporcional à média das remunerações cadastradas</small></div>
      <div className="salary-pillars">{averages.sort((a,b)=>b.avg-a.avg).map(item=><button key={item.uf} className={selected===item.uf?"salary-state active":"salary-state"} onClick={()=>setSelected(item.uf===selected?"":item.uf)} title={item.avg?money(item.avg):"Sem remuneração cadastrada"}><span className="salary-value">{item.avg?money(item.avg):"—"}</span><span className="salary-pillar-track"><i style={{height:item.avg?Math.max(5,item.avg/maxAverage*100)+"%":"4px",background:regions[item.uf].color}}/></span><b>{item.uf}</b></button>)}</div>
      <p className="national-map-note">A média considera apenas concursos com remuneração mínima ou máxima cadastrada. Estados sem dados salariais não recebem pilar estimado.</p>
    </section>
    {showAuthorized&&<section className="authorized-list-panel"><div className="national-panel-heading"><div><span className="eyebrow">EDITAIS AINDA NÃO PUBLICADOS</span><h3>Concursos com autorização oficial</h3></div><strong>{filteredAuthorizations.length} registros</strong></div><label className="authorized-search"><Search size={17}/><input value={authSearch} onChange={e=>setAuthSearch(e.target.value)} placeholder="Buscar órgão, cargo ou estado..."/></label>{loading?<p>Carregando autorizações...</p>:filteredAuthorizations.length?<div className="authorization-list">{filteredAuthorizations.map(a=><article className="authorization-card" key={a.id}><div><span className="authorization-state">{a.state||"Federal"}{a.city?" • "+a.city:""}</span><h4>{a.title}</h4><p>{a.agency}</p>{a.positions&&<p><b>Cargos:</b> {a.positions}</p>}<div className="authorization-meta">{a.vacancies!=null&&<span>{a.vacancies} vagas</span>}{(a.salary_min||a.salary_max)&&<span>{money(Number(a.salary_min||a.salary_max))}{a.salary_max&&a.salary_min&&a.salary_max!==a.salary_min?" a "+money(Number(a.salary_max)):""}</span>}<span>{a.status==="authorized"?"Autorizado":"Em preparação"}</span></div>{a.notes&&<small>{a.notes}</small>}</div>{a.source_url&&<a href={a.source_url} target="_blank" rel="noreferrer" className="button button-outline">Fonte oficial <ExternalLink size={14}/></a>}</article>)}</div>:<p className="national-empty">Nenhuma autorização cadastrada para este filtro. A lista será alimentada com atos e fontes oficiais.</p>}</section>}
    <section className="state-results"><div className="national-panel-heading"><div><span className="eyebrow">{selected?"ESTADO SELECIONADO":"VISÃO NACIONAL"}</span><h3>{selected?selectedName:"Editais publicados e oportunidades"}</h3></div><strong>{stateContests.length} concursos</strong></div>{stateContests.length?<div className="national-contest-list">{stateContests.map(c=><article className="national-contest-card" key={c.id}><div><span className="authorization-state">{c.state||"Federal"}{c.city?" • "+c.city:""}</span><h4>{c.title}</h4><div className="authorization-meta">{c.employment_type==="temporary"&&<span>Processo seletivo temporário</span>}{c.employment_type==="public_enterprise"&&<span>Empresa pública</span>}{c.level&&<span>{c.level}</span>}{c.vacancies!=null&&<span>{c.vacancies} vagas</span>}{(c.salary_min||c.salary_max)&&<span>{money(Number(c.salary_min||c.salary_max))}{c.salary_max&&c.salary_min&&c.salary_max!==c.salary_min?" a "+money(Number(c.salary_max)):""}</span>}{c.deadline&&<span>Inscrições até {new Date(c.deadline+"T12:00:00").toLocaleDateString("pt-BR")}</span>}</div></div><div className="national-card-links">{c.registration_url&&<a href={c.registration_url} target="_blank" rel="noreferrer">Inscrição <ExternalLink size={13}/></a>}{c.official_url&&<a href={c.official_url} target="_blank" rel="noreferrer">Edital oficial <ExternalLink size={13}/></a>}{c.source_url&&<a href={c.source_url} target="_blank" rel="noreferrer">Fonte consultada <ExternalLink size={13}/></a>}</div></article>)}</div>:<p className="national-empty">Nenhum edital publicado cadastrado {selected?"para "+selectedName:"neste momento"}. Os registros nacionais serão adicionados à medida que forem verificados.</p>}</section>
  </section>;
}
function centroid(g:any):number[]{let pts:number[][]=[];const walk=(v:any)=>{if(Array.isArray(v)&&typeof v[0]==="number")pts.push(v);else if(Array.isArray(v))v.forEach(walk)};walk(g?.coordinates||[]);if(!pts.length)return [-50,-15];return [pts.reduce((s,p)=>s+p[0],0)/pts.length,pts.reduce((s,p)=>s+p[1],0)/pts.length];}
