document.documentElement.dataset.theme='light';
try { const value=localStorage.getItem('ot_theme'); if(value==='dark'||value==='light')document.documentElement.dataset.theme=value; } catch {}
