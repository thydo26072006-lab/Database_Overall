export default function StatusBadge({ active, inactiveWarning, children }) {
  const variant = active ? ' status-badge-active' : inactiveWarning ? ' status-badge-warning' : '';
  return <span className={`status-badge${variant}`}>{children}</span>;
}
