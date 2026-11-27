const demoStatus = document.getElementById('status');
const openApp = document.getElementById('open-app');

async function showDemoLink() {
  try {
    const response = await fetch('./demo.json', { cache: 'no-store' });
    if (!response.ok) throw new Error('Cannot load demo settings');
    const { url } = await response.json();
    const tunnelUrl = /^https:\/\/[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.trycloudflare\.com\/?$/i;
    if (typeof url !== 'string' || !tunnelUrl.test(url)) {
      demoStatus.textContent = 'Demo chưa mở. Tải lại trang khi buổi demo bắt đầu.';
      return;
    }
    openApp.href = url;
    openApp.hidden = false;
    demoStatus.textContent = 'Ứng dụng mở trong buổi demo. Nếu đường dẫn tạm thời hết hạn, hãy tải lại trang này.';
  } catch {
    demoStatus.textContent = 'Chưa tải được đường dẫn demo. Hãy tải lại trang.';
  }
}

showDemoLink();
