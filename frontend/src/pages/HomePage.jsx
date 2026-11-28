import './homePage.css';

export default function HomePage({ features }) {
  return (
    <div className="home-page">
      <header className="home-intro">
        <h1>Hệ thống quản lý gọi món và đặt món</h1>
        <p>Quản lý thực đơn, cấu hình size món và theo dõi phân công bàn theo ca.</p>
      </header>

      <section aria-labelledby="home-features-title">
        <h2 id="home-features-title">Chức năng</h2>
        <ul className="home-features">
          {features.map(({ path, label, description, sql }) => (
            <li className="home-card" key={path}>
              <h3><a href={path}>{label} <span aria-hidden="true">→</span></a></h3>
              <p>{description}</p>
              <ul className="home-sql" aria-label="Đối tượng SQL">
                {sql.map(name => <li key={name}><code>{name}</code></li>)}
              </ul>
            </li>
          ))}
        </ul>
      </section>

      <section className="home-architecture" aria-labelledby="home-architecture-title">
        <h2 id="home-architecture-title">Kiến trúc hệ thống</h2>
        <p>Giao diện React gửi yêu cầu đến API Express. SQL Server thực thi thủ tục, chạy trigger và lưu dữ liệu.</p>
      </section>
    </div>
  );
}
