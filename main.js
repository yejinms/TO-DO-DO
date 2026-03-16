const { app, BrowserWindow, ipcMain, screen } = require('electron');
const path = require('path');
const fs = require('fs');

let mainWindow;

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
    alwaysOnTop: true,
    skipTaskbar: true,          // Dock/Taskbar에 표시 안 함
    focusable: true,
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true,
      preload: path.join(__dirname, 'preload.js'),
    },
  });

  mainWindow.loadFile(path.join(__dirname, 'src', 'index.html'));

  // macOS 전용: 모든 스페이스(가상 데스크탑)에 표시
  mainWindow.setVisibleOnAllWorkspaces(true, { visibleOnFullScreen: false });

  // 다른 앱 위에 뜨되, 일반 창보다는 낮은 레벨 (진짜 위젯 느낌)
  mainWindow.setAlwaysOnTop(true, 'floating');

  // macOS Dock에서 숨기기
  if (process.platform === 'darwin' && app.dock) {
    app.dock.hide();
  }

  // Uncomment to open DevTools during development
  // mainWindow.webContents.openDevTools();
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
  app.quit();
});

ipcMain.on('minimize-window', () => {
  mainWindow.minimize();
});

app.whenReady().then(createWindow);

app.on('window-all-closed', () => {
  app.quit();
});

app.on('activate', () => {
  if (BrowserWindow.getAllWindows().length === 0) createWindow();
});
