const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('api', {
  getTodos: (date) => ipcRenderer.invoke('get-todos', date),
  saveTodos: (date, todos) => ipcRenderer.invoke('save-todos', date, todos),
  getAllDates: () => ipcRenderer.invoke('get-all-dates'),
  deleteDate: (date) => ipcRenderer.invoke('delete-date', date),
  closeWindow: () => ipcRenderer.send('close-window'),
  minimizeWindow: () => ipcRenderer.send('minimize-window'),
});
