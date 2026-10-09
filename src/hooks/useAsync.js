import { useEffect, useRef, useState } from "react";

// Runs an async function and tracks { data, error, loading }. Re-runs when `deps` change or reload() is called.
// Results from a stale run (deps changed / component unmounted) are ignored.
export function useAsync(fn, deps = []) {
  const [state, setState] = useState({ data: null, error: null, loading: true });
  const [nonce, setNonce] = useState(0);
  const fnRef = useRef(fn);
  fnRef.current = fn;

  useEffect(() => {
    let cancelled = false;
    setState({ data: null, error: null, loading: true });
    Promise.resolve()
      .then(() => fnRef.current())
      .then((data) => { if (!cancelled) setState({ data, error: null, loading: false }); })
      .catch((error) => { if (!cancelled) setState({ data: null, error, loading: false }); });
    return () => { cancelled = true; };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [...deps, nonce]);

  return { ...state, reload: () => setNonce((n) => n + 1) };
}
