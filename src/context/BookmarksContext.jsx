import React, { createContext, useCallback, useContext, useEffect, useMemo, useState } from "react";
import { prepNestApi } from "../services/api";

const BookmarksContext = createContext(null);
const keyOf = (type, id) => `${type}:${id}`;

// Loads the user's bookmarks from the backend (Supabase) once and keeps them in sync.
export function BookmarksProvider({ children }) {
  const [items, setItems] = useState([]);
  const [status, setStatus] = useState("loading"); // loading | ready | error
  const [error, setError] = useState(null);

  const load = useCallback(async () => {
    setStatus("loading");
    try {
      setItems(await prepNestApi.bookmarks());
      setError(null);
      setStatus("ready");
    } catch (e) {
      setError(e);
      setStatus("error");
    }
  }, []);

  useEffect(() => { load(); }, [load]);

  const saved = useMemo(() => new Set(items.map((b) => keyOf(b.item_type, b.item_id))), [items]);
  const isBookmarked = useCallback((type, id) => saved.has(keyOf(type, id)), [saved]);

  const toggle = useCallback(async (item) => {
    const k = keyOf(item.item_type, item.item_id);
    try {
      if (saved.has(k)) {
        setItems((cur) => cur.filter((b) => keyOf(b.item_type, b.item_id) !== k));
        await prepNestApi.deleteBookmark(item);
      } else {
        setItems((cur) => [{ ...item, id: `tmp-${k}`, created_at: new Date().toISOString() }, ...cur]);
        const row = await prepNestApi.saveBookmark(item);
        setItems((cur) => cur.map((b) => (keyOf(b.item_type, b.item_id) === k ? row : b)));
      }
    } catch (e) {
      setError(e);
      await load(); // roll back to what the server really has
    }
  }, [saved, load]);

  const remove = useCallback((item) => toggle(item), [toggle]);

  const value = useMemo(
    () => ({ items, status, error, isBookmarked, toggle, remove, reload: load }),
    [items, status, error, isBookmarked, toggle, remove, load]
  );
  return <BookmarksContext.Provider value={value}>{children}</BookmarksContext.Provider>;
}

export function useBookmarks() {
  const ctx = useContext(BookmarksContext);
  if (!ctx) throw new Error("useBookmarks must be used inside <BookmarksProvider>");
  return ctx;
}
