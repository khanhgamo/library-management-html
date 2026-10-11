// VAU Digital Library (bản HTML tĩnh) - chỉ UI, không backend.
// - Xác nhận xóa (data-confirm)
// - Tự ẩn alert sau 5s
// - Lọc sách client-side ở catalog.html (?q=)
document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('[data-confirm]').forEach(el => {
    el.addEventListener('click', (ev) => {
      if (!confirm(el.getAttribute('data-confirm'))) ev.preventDefault();
    });
  });
  setTimeout(() => {
    document.querySelectorAll('.alert').forEach(a => {
      a.style.transition = 'opacity .5s'; a.style.opacity = '0';
      setTimeout(() => a.remove(), 600);
    });
  }, 5000);

  // Lọc client-side theo ?q= cho catalog (demo tĩnh, thay cho SQL LIKE)
  try {
    const params = new URLSearchParams(location.search);
    const q = (params.get('q') || '').trim().toLowerCase();
    const box = document.getElementById('q');
    if (box && q) box.value = params.get('q');
    if (q) {
      document.querySelectorAll('#bookGrid .card').forEach(card => {
        const t = (card.getAttribute('data-title') || card.textContent).toLowerCase();
        if (!t.includes(q)) card.style.display = 'none';
      });
    }
  } catch (e) { /* bỏ qua */ }
});
