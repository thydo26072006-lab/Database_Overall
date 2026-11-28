import '../styles/layout.css';

export default function AppLayout({ currentPath, pages, children }) {
  return (
    <>
      <a className="app-skip-link" href="#app-content">Đến nội dung chính</a>
      <header className="app-header" id="app-header" tabIndex={-1}>
        <div className="app-header-inner">
          <a className="app-name" href="/#">Quản lý gọi món</a>
          <nav aria-label="Điều hướng chính">
            <ul className="app-nav">
              {pages.map(({ path, label }) => (
                <li key={path}>
                  <a href={path} aria-current={currentPath === path ? 'page' : undefined}>
                    {label}
                  </a>
                </li>
              ))}
            </ul>
          </nav>
        </div>
      </header>
      <main className="app-content" id="app-content" tabIndex={-1}>{children}</main>
      <footer className="app-footer">
        <a href="#">Về đầu trang</a>
      </footer>
    </>
  );
}
