import './globals.css';
import ThemeRegistry from '@/components/ThemeRegistry';
import I18nProvider from '@/components/I18nProvider';
import { Toaster } from 'sonner';
import { Provider } from 'jotai';

export const metadata = {
  title: '数据预处理',
  description: '一个强大的 LLM 数据集预处理工具',
  icons: {
    icon: '/imgs/logo.ico' // 更新为正确的文件名
  }
};

export default function RootLayout({ children }) {
  return (
    <html lang="zh" suppressHydrationWarning>
      <body suppressHydrationWarning>
        <Provider>
          <ThemeRegistry>
            <I18nProvider>
              {children}
              <Toaster richColors position="top-right" duration={1000} />
            </I18nProvider>
          </ThemeRegistry>
        </Provider>
      </body>
    </html>
  );
}
