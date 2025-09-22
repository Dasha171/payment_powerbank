# 🚀 Инструкции по деплою Power Bank Rental Web App

## ✅ Что уже реализовано

### ✅ Основная функциональность
- [x] **API Client** - Полная интеграция с backend API
- [x] **Payment Service** - Сервис для работы с Apple Pay и Braintree
- [x] **Auth Service** - Сервис аутентификации
- [x] **Payment Screen** - Экран оплаты согласно Figma дизайну
- [x] **Success Screen** - Экран подтверждения успешной оплаты
- [x] **Deep Links** - Поддержка QR-кодов и URL параметров
- [x] **Web Configuration** - Настроенный манифест и HTML

### ✅ UI/UX компоненты
- [x] **AppButton** - Переиспользуемая кнопка
- [x] **ErrorView** - Компонент для отображения ошибок
- [x] **Loader** - Индикаторы загрузки
- [x] **PaymentProvider** - Управление состоянием

### ✅ Интеграции
- [x] **Braintree JS SDK** - Полная интеграция
- [x] **Apple Pay JS** - Базовая интеграция (требует server-side validation)
- [x] **Go Router** - Навигация и роутинг
- [x] **Provider** - State management

## 🔧 Что нужно настроить перед деплоем

### 1. Apple Pay Domain Verification
```html
<!-- В web/index.html заменить -->
<meta name="apple-pay-domain-verification" content="YOUR_DOMAIN_VERIFICATION_CODE">
```

**Как получить:**
1. Обратиться к @kareemnba в Telegram
2. Предоставить домен для верификации
3. Получить verification code от Apple
4. Добавить в HTML

### 2. Braintree Configuration
```dart
// В lib/services/api_client.dart проверить baseUrl
static const String baseUrl = 'https://goldfish-app-3lf7u.ondigitalocean.app';
```

**Настройки в Braintree Dashboard:**
- [ ] Включить Apple Pay
- [ ] Настроить webhook endpoints
- [ ] Проверить API ключи
- [ ] Настроить merchant ID

### 3. CORS настройки
Убедиться, что backend разрешает запросы с вашего домена.

### 4. SSL сертификат
Обязательно HTTPS для работы Apple Pay и Braintree.

## 🚀 Команды для деплоя

### Локальная разработка
```bash
# Установка зависимостей
flutter pub get

# Запуск в режиме разработки
flutter run -d web-server --web-port 3000

# Тестирование с тестовой станцией
# Откройте: http://localhost:3000/?stationId=RECH082203000350
```

### Продакшен сборка
```bash
# Сборка для продакшена
flutter build web --release

# Файлы будут в папке build/web/
```

### Деплой на Vercel
```bash
# Установка Vercel CLI
npm i -g vercel

# Деплой
vercel --prod --dir build/web
```

### Деплой на Netlify
```bash
# Установка Netlify CLI
npm i -g netlify-cli

# Деплой
netlify deploy --prod --dir build/web
```

### Деплой на Firebase Hosting
```bash
# Установка Firebase CLI
npm i -g firebase-tools

# Инициализация
firebase init hosting

# Деплой
firebase deploy --only hosting
```

## 🧪 Тестирование

### Тестовые данные
- **Station ID**: `RECH082203000350`
- **Test URL**: `https://yourdomain.com/?stationId=RECH082203000350`

### Тестовые сценарии
1. **QR Code Flow**: Открыть URL с stationId
2. **Apple Pay**: Проверить доступность на iOS устройствах
3. **Card Payment**: Тестировать через Braintree Drop-in
4. **Error Handling**: Проверить обработку ошибок
5. **Mobile Responsive**: Тестировать на разных устройствах

## 📱 Мобильная оптимизация

### PWA настройки
- [x] Манифест настроен
- [x] Иконки добавлены
- [x] Meta теги для iOS

### Responsive дизайн
- [x] Адаптивная верстка
- [x] Touch-friendly кнопки
- [x] Оптимизация для мобильных

## 🔒 Безопасность

### Обязательные проверки
- [ ] HTTPS включен
- [ ] CORS настроен
- [ ] API ключи защищены
- [ ] Domain verification для Apple Pay
- [ ] Braintree webhooks настроены

## 📊 Мониторинг

### Логирование
```dart
// Все API запросы логируются через Dio interceptor
_dio.interceptors.add(LogInterceptor(
  requestBody: true,
  responseBody: true,
  error: true,
));
```

### Аналитика
- Braintree Dashboard для платежей
- Apple Pay Analytics
- Custom error tracking

## 🆘 Поддержка

### Контакты
- **Telegram**: @kareemnba
- **Backend API**: https://goldfish-app-3lf7u.ondigitalocean.app/swagger-ui/

### Частые проблемы
1. **Apple Pay не работает** → Проверить domain verification
2. **Braintree ошибки** → Проверить API ключи
3. **CORS ошибки** → Настроить CORS на сервере
4. **Deep links не работают** → Проверить URL параметры

## 📋 Чек-лист перед запуском

### Техническая готовность
- [ ] Flutter проект собирается без ошибок
- [ ] Все зависимости установлены
- [ ] API endpoints доступны
- [ ] Braintree настроен
- [ ] Apple Pay domain verified
- [ ] SSL сертификат установлен

### Функциональное тестирование
- [ ] QR код сканирование работает
- [ ] Payment screen отображается корректно
- [ ] Apple Pay доступен на iOS
- [ ] Card payment работает
- [ ] Success screen показывается
- [ ] Error handling работает
- [ ] Mobile responsive

### Продакшен готовность
- [ ] Домен настроен
- [ ] DNS записи настроены
- [ ] CDN настроен (опционально)
- [ ] Мониторинг настроен
- [ ] Backup стратегия
- [ ] Rollback план

---

## 🎉 Готово к запуску!

Проект полностью реализован согласно ТЗ. Осталось только:
1. Настроить домен и SSL
2. Получить Apple Pay domain verification
3. Проверить Braintree настройки
4. Задеплоить на выбранную платформу

**Удачного запуска! 🚀**
