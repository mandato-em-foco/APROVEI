import { createClient } from "@supabase/supabase-js";

const url = import.meta.env.VITE_SUPABASE_URL as string | undefined;
const anonKey = import.meta.env.VITE_SUPABASE_ANON_KEY as string | undefined;

const sessionStorageAdapter = {
  getItem: (key: string) => {
    if (typeof window === "undefined") return null;
    const remember = window.localStorage.getItem("aprovei-remember-session") !== "false";
    return remember
      ? window.localStorage.getItem(key)
      : window.sessionStorage.getItem(key);
  },
  setItem: (key: string, value: string) => {
    if (typeof window === "undefined") return;
    const remember = window.localStorage.getItem("aprovei-remember-session") !== "false";
    if (remember) {
      window.localStorage.setItem(key, value);
      window.sessionStorage.removeItem(key);
    } else {
      window.sessionStorage.setItem(key, value);
      window.localStorage.removeItem(key);
    }
  },
  removeItem: (key: string) => {
    if (typeof window === "undefined") return;
    window.localStorage.removeItem(key);
    window.sessionStorage.removeItem(key);
  }
};

export const isSupabaseConfigured = Boolean(url && anonKey && !url.includes("SEU-PROJETO"));

export const supabase = isSupabaseConfigured
  ? createClient(url!, anonKey!, {
      auth: {
        storage: sessionStorageAdapter,
        persistSession: true,
        autoRefreshToken: true,
        detectSessionInUrl: true
      }
    })
  : null;
