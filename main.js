const { app, BrowserWindow, ipcMain, screen, Tray, Menu, nativeImage } = require('electron');
const path = require('path');
const fs = require('fs');

let mainWindow;
let tray;

function getDataPath() {
  return path.join(app.getPath('userData'), 'todos.json');
}

function loadAllData() {
  const dataPath = getDataPath();
  if (!fs.existsSync(dataPath)) {
    fs.writeFileSync(dataPath, JSON.stringify({}), 'utf-8');
    return {};
  }
  try {
    return JSON.parse(fs.readFileSync(dataPath, 'utf-8'));
  } catch {
    return {};
  }
}

function saveAllData(data) {
  fs.writeFileSync(getDataPath(), JSON.stringify(data, null, 2), 'utf-8');
}

function createWindow() {
  const { width, height } = screen.getPrimaryDisplay().workAreaSize;

  mainWindow = new BrowserWindow({
    width: 420,
    height: 700,
    x: width - 460,
    y: 40,
    frame: false,
    transparent: true,
    resizable: true,
    hasShadow: true,
    // Widget behavior
    alwaysOnTop: false,
    skipTaskbar: true,
    focusable: true,            // 투두 입력을 위해 포커스는 유지
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true,
      preload: path.join(__dirname, 'preload.js'),
    },
  });

  mainWindow.loadFile(path.join(__dirname, 'src', 'index.html'));

  // macOS 전용: 모든 스페이스(가상 데스크탑)에 표시
  mainWindow.setVisibleOnAllWorkspaces(true, { visibleOnFullScreen: false });

  // 배경 고정: 모든 창 뒤에 깔림 (배경화면 바로 위)
  mainWindow.setAlwaysOnTop(false);
  if (process.platform === 'darwin') {
    mainWindow.setWindowButtonVisibility(false);
  }

  // macOS Dock에서 숨기기
  if (process.platform === 'darwin' && app.dock) {
    app.dock.hide();
  }

  createTray();

  // Uncomment to open DevTools during development
  // mainWindow.webContents.openDevTools();
}

function createTray() {
  // 16×16 오렌지 원 아이콘을 코드로 생성 (별도 이미지 파일 불필요)
  const icon = nativeImage.createFromDataURL(
    'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/' +
    '9hAAAAZklEQVQ4T2NkYGD4z8BAAiYlJf+JNYBkA0g2gBQDSDaAFAMoZgApBlDM' +
    'AFIMoJgBpBhAMQNIMYBiBpBiAMUMIMUAihlAigEUM4AUAyhmACkGUMwAUgygmAGk' +
    'GEAxA0gxgGIGAABZoAAR/6sRIgAAAABJRU5ErkJggg=='
  );

  // 메뉴바에 텍스트로 표시 (이미지보다 명확)
  tray = new Tray(nativeImage.createEmpty());
  tray.setTitle('✦ TODO');
  tray.setToolTip('TO-DO-DO');

  const menu = Menu.buildFromTemplate([
    {
      label: '위젯 보이기 / 숨기기',
      click: () => {
        if (mainWindow.isVisible()) {
          mainWindow.hide();
        } else {
          mainWindow.show();
          mainWindow.focus();
        }
      },
    },
    { type: 'separator' },
    {
      label: '종료',
      click: () => app.quit(),
    },
  ]);

  tray.setContextMenu(menu);

  // 메뉴바 아이콘 클릭 시 토글
  tray.on('click', () => {
    if (mainWindow.isVisible()) {
      mainWindow.hide();
    } else {
      mainWindow.show();
      mainWindow.focus();
    }
  });
}

// IPC handlers
ipcMain.handle('get-todos', (event, date) => {
  const data = loadAllData();
  return data[date] || [];
});

ipcMain.handle('save-todos', (event, date, todos) => {
  const data = loadAllData();
  data[date] = todos;
  saveAllData(data);
  return true;
});

ipcMain.handle('get-all-dates', () => {
  const data = loadAllData();
  return Object.keys(data).sort();
});

ipcMain.handle('delete-date', (event, date) => {
  const data = loadAllData();
  delete data[date];
  saveAllData(data);
  return true;
});

ipcMain.on('close-window', () => {
  // 완전 종료 대신 숨기기 (메뉴바에서 다시 열 수 있음)
  mainWindow.hide();
});

ipcMain.on('minimize-window', () => {
  mainWindow.hide();
});

app.whenReady().then(createWindow);

app.on('window-all-closed', () => {
  app.quit();
});

app.on('activate', () => {
  if (BrowserWindow.getAllWindows().length === 0) createWindow();
});
