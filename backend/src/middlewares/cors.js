const allowedMethods = ['GET', 'HEAD', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'];
const allowedHeaders = ['content-type'];

export function createCors(corsOrigins) {
  const origins = new Set(corsOrigins);

  return (request, response, next) => {
    const origin = request.get('Origin');
    const requestedMethod = request.get('Access-Control-Request-Method');
    const allowedOrigin = origins.has(origin);

    response.vary('Origin');
    if (allowedOrigin) response.set('Access-Control-Allow-Origin', origin);

    if (request.method !== 'OPTIONS') return next();

    response.vary('Access-Control-Request-Method');
    response.vary('Access-Control-Request-Headers');
    if (!origin || !requestedMethod) return next();

    const requestedHeaders = request.get('Access-Control-Request-Headers') ?? '';
    const headersAllowed = !requestedHeaders || requestedHeaders.split(',').every(
      header => allowedHeaders.includes(header.trim().toLowerCase()),
    );

    if (!allowedOrigin || !allowedMethods.includes(requestedMethod) || !headersAllowed) {
      return response.status(403).json({
        error: { code: 'CORS_DENIED', message: 'Yêu cầu CORS không được phép.' },
      });
    }

    response.set('Access-Control-Allow-Methods', allowedMethods.join(', '));
    response.set('Access-Control-Allow-Headers', allowedHeaders.join(', '));
    return response.status(204).end();
  };
}
