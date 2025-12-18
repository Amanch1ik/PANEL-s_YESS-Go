import React from 'react';
import { Navigate } from 'react-router-dom';
import { Spin } from 'antd';
import { useAuth } from '@/hooks/useAuth';

const ADMIN_TOKEN_KEY = 'admin_token';
const ADMIN_MOCK_FLAG_KEY = 'admin_is_mock_login';
const MOCK_ADMIN_TOKEN = 'mock_admin_token';

interface ProtectedRouteProps {
  children: React.ReactNode;
}

export const ProtectedRoute = ({ children }: ProtectedRouteProps) => {
  const { isLoading } = useAuth();

  // Проверяем токен напрямую, чтобы не зависеть от состояния загрузки
  const token = localStorage.getItem(ADMIN_TOKEN_KEY);
  const isMockSession = token === MOCK_ADMIN_TOKEN || localStorage.getItem(ADMIN_MOCK_FLAG_KEY) === 'true';

  // Если загрузка длится слишком долго (больше 3 секунд), проверяем токен напрямую
  const [hasTimedOut, setHasTimedOut] = React.useState(false);

  React.useEffect(() => {
    if (isLoading) {
      const timer = setTimeout(() => {
        setHasTimedOut(true);
      }, 3000); // 3 секунды таймаут

      return () => clearTimeout(timer);
    } else {
      setHasTimedOut(false);
    }
  }, [isLoading]);

  // Если нет токена, сразу редиректим на логин
  if (!token) {
    return <Navigate to="/login" replace />;
  }

  // Если загрузка и не прошло 3 секунды, показываем спиннер
  if (!isMockSession && isLoading && !hasTimedOut) {
    return (
      <div style={{
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center',
        minHeight: '100vh',
        background: 'linear-gradient(135deg, #689071 0%, #AEC380 50%, #E3EED4 100%)',
      }}>
        <Spin size="large" />
        <span style={{ marginLeft: 16, color: '#0F2A1D' }}>Загрузка...</span>
      </div>
    );
  }

  // Если токен есть, разрешаем доступ (даже если isAuthenticated еще false)
  // useAuth установит пользователя в фоне
  return <>{children}</>;
};
