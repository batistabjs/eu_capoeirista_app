# Eu Capoeirista App — Flutter Web

App Flutter para listagem de eventos de Capoeira no Brasil através do Google Calendar. Consome a [Google Calendar API v3](https://developers.google.com/workspace/calendar/api/v3/reference) com autenticação OAuth 2.0.

---

## Pré-requisitos

- **Flutter SDK** `>=3.0.0` — [Instalar Flutter](https://docs.flutter.dev/get-started/install)
- **Conta Google Cloud** para criar credenciais OAuth

Verifique a instalação:

```bash
flutter doctor
flutter --version
```

---

## Configuração do Google Cloud Console

> **Obrigatório antes de executar.** Sem as credenciais OAuth, o login não funcionará.

### 1. Criar Projeto no Google Cloud Console

1. Acesse [console.cloud.google.com](https://console.cloud.google.com)
2. Clique em **"Selecionar projeto"** → **"Novo projeto"**
3. Dê um nome (ex: `eu-capoeirista-app`) e clique em **"Criar"**

### 2. Ativar a Google Calendar API

1. No menu lateral, vá em **"APIs e Serviços"** → **"Biblioteca"**
2. Pesquise por **"Google Calendar API"**
3. Clique em **"Ativar"**

### 3. Configurar a Tela de Consentimento OAuth

1. Vá em **"APIs e Serviços"** → **"Tela de consentimento OAuth"**
2. Escolha **"Externo"** e clique em **"Criar"**
3. Preencha os campos obrigatórios:
   - **Nome do aplicativo**: Eu Capoeirista App
   - **E-mail de suporte**: seu e-mail
   - **E-mail do desenvolvedor**: seu e-mail
4. Em **"Escopos"**, adicione:
   - `https://www.googleapis.com/auth/calendar.readonly`
   - `email`
   - `profile`
5. Em **"Usuários de teste"**, adicione seu e-mail Google
6. Clique em **"Salvar e continuar"**

### 4. Criar Credencial OAuth 2.0

1. Vá em **"APIs e Serviços"** → **"Credenciais"**
2. Clique em **"+ Criar credenciais"** → **"ID do cliente OAuth"**
3. Tipo: **"Aplicativo da Web"**
4. Nome: `Eu Capoeirista Web`
5. Em **"Origens JavaScript autorizadas"**, adicione:
   ```
   http://localhost:5000
   http://localhost:8080
   ```
6. Em **"URIs de redirecionamento autorizados"**, adicione:
   ```
   http://localhost:5000
   http://localhost:8080
   ```
7. Clique em **"Criar"**
8. **Copie o Client ID** (formato: `XXXXXXXX.apps.googleusercontent.com`)

---

## Configuração do Projeto

### 1. Inserir o Client ID no HTML

Abra `web/index.html` e substitua o valor na meta tag:

```html
<!-- Linha 14 de web/index.html -->
<meta name="google-signin-client_id" content="SEU_CLIENT_ID.apps.googleusercontent.com">
```

### 2. Inserir o Client ID no AuthService

Abra `lib/services/auth_service.dart` e substitua:

```dart
// lib/services/auth_service.dart — linha ~18
late final GoogleSignIn _googleSignIn = GoogleSignIn(
  clientId: 'SEU_CLIENT_ID.apps.googleusercontent.com', // ← substitua aqui
  scopes: _scopes,
);
```

**Ou** use variável de ambiente:

```bash
flutter run -d chrome --web-port=5000 \
  --dart-define=GOOGLE_CLIENT_ID=SEU_CLIENT_ID.apps.googleusercontent.com
```

---

## Instalação e Execução

### 1. Clonar / Entrar no diretório

```bash
cd eu-capoeirista-app
```

### 2. Instalar dependências

```bash
flutter pub get
```

### 3. Verificar target web

```bash
flutter devices
# Deve listar: Chrome (web)
```

### 4. Executar em modo desenvolvimento

```bash
# Porta padrão
flutter run -d chrome

# Porta específica (deve coincidir com o autorizado no Google Cloud)
flutter run -d chrome --web-port=5000
```

A aplicação abrirá automaticamente no Chrome.

---

## Debug

### Debug no VS Code

1. Instale as extensões **Flutter** e **Dart**
2. Abra o projeto no VS Code
3. Crie `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Flutter Web (Chrome)",
      "type": "dart",
      "request": "launch",
      "program": "lib/main.dart",
      "args": [
        "--web-port=5000",
        "--dart-define=GOOGLE_CLIENT_ID=SEU_CLIENT_ID.apps.googleusercontent.com"
      ]
    }
  ]
}
```

4. Pressione **F5** para iniciar com debug

### Debug no Android Studio / IntelliJ

1. Abra o projeto
2. Selecione o device **Chrome**
3. Em **Run/Debug Configurations**, adicione em "Additional run args":
   ```
   --web-port=5000
   ```
4. Clique em **Debug** (ícone de bug)

### Debug pelo Terminal com DevTools

```bash
flutter run -d chrome --web-port=5000
```

No terminal, pressione **d** para abrir o Flutter DevTools no browser.

### Logs úteis

```bash
# Ver logs detalhados
flutter run -d chrome --verbose

# Build para web (produção) e inspecionar
flutter build web
cd build/web && python3 -m http.server 8080
```

---

## Endpoints da Google Calendar API Utilizados

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| `GET` | `/users/me/calendarList` | Lista todos os calendários do usuário |
| `GET` | `/calendars/{calendarId}/events` | Lista eventos com filtros de data, paginação e busca |
| `GET` | `/calendars/{calendarId}/events/{eventId}` | Detalhe completo de um evento |

### Parâmetros da listagem de eventos

| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `timeMin` | datetime | Data/hora mínima dos eventos (ISO 8601) |
| `timeMax` | datetime | Data/hora máxima dos eventos |
| `maxResults` | int | Máximo de resultados (padrão: 50) |
| `singleEvents` | bool | Expande eventos recorrentes individualmente |
| `orderBy` | string | Ordenação: `startTime` ou `updated` |
| `pageToken` | string | Token para próxima página (paginação) |
| `q` | string | Pesquisa de texto livre |

---
