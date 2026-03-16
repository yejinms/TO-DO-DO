/* ============================
   TO-DO-DO — App Logic
   ============================ */

'use strict';

// ── State ──────────────────────────────────────────────────
let todos       = [];          // current day's todo array
let allDates    = [];          // all dates with saved todos
let viewingDate = '';          // YYYY-MM-DD currently shown
const todayDate = getDateKey(new Date());

// ── Helpers ────────────────────────────────────────────────
function getDateKey(date) {
  const y = date.getFullYear();
  const m = String(date.getMonth() + 1).padStart(2, '0');
  const d = String(date.getDate()).padStart(2, '0');
  return `${y}-${m}-${d}`;
}

function formatDisplayDate(dateKey) {
  const [y, m, d] = dateKey.split('-').map(Number);
  const date = new Date(y, m - 1, d);
  const days  = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
  const months= ['JAN','FEB','MAR','APR','MAY','JUN',
                  'JUL','AUG','SEP','OCT','NOV','DEC'];
  return `${days[date.getDay()]} / ${months[m - 1]} ${d}`;
}

function isToday(dateKey) {
  return dateKey === todayDate;
}

// ── Data I/O ───────────────────────────────────────────────
async function refreshAllDates() {
  allDates = await window.api.getAllDates();
  // Always ensure today is reachable even if no data yet
  if (!allDates.includes(todayDate)) {
    allDates.push(todayDate);
    allDates.sort();
  }
}

async function loadDate(dateKey) {
  viewingDate = dateKey;
  todos = await window.api.getTodos(dateKey);
  // New day → start with empty list (don't carry over)
  if (!todos) todos = [];
  render();
}

async function persistTodos() {
  await window.api.saveTodos(viewingDate, todos);
  await refreshAllDates();
}

// ── CRUD ───────────────────────────────────────────────────
function addTodo(text) {
  text = text.trim();
  if (!text) return;
  todos.push({ id: Date.now(), text, done: false, priority: false });
  sortTodos();
  persistTodos();
  render();
}

function toggleDone(id) {
  const item = todos.find(t => t.id === id);
  if (item) {
    item.done = !item.done;
    persistTodos();
    render();
  }
}

function togglePriority(id) {
  const item = todos.find(t => t.id === id);
  if (item) {
    item.priority = !item.priority;
    sortTodos();
    persistTodos();
    render();
  }
}

function deleteTodo(id) {
  todos = todos.filter(t => t.id !== id);
  persistTodos();
  render();
}

function updateText(id, newText) {
  newText = newText.trim();
  if (!newText) { deleteTodo(id); return; }
  const item = todos.find(t => t.id === id);
  if (item) {
    item.text = newText;
    persistTodos();
  }
}

function sortTodos() {
  // Priority items first, then by insertion order (id)
  todos.sort((a, b) => {
    if (a.priority !== b.priority) return b.priority - a.priority;
    return a.id - b.id;
  });
}

// ── Navigation ─────────────────────────────────────────────
async function navigate(direction) {
  await refreshAllDates();
  const idx = allDates.indexOf(viewingDate);
  const newIdx = idx + direction;
  if (newIdx < 0 || newIdx >= allDates.length) return;
  await loadDate(allDates[newIdx]);
}

// ── Render ─────────────────────────────────────────────────
function render() {
  renderDate();
  renderTodos();
  renderNavButtons();
  renderPastMode();
}

function renderDate() {
  const el = document.getElementById('date-display');
  const badge = document.getElementById('today-badge');
  el.textContent = formatDisplayDate(viewingDate);
  badge.classList.toggle('visible', isToday(viewingDate));
}

function renderNavButtons() {
  const idx     = allDates.indexOf(viewingDate);
  const prevBtn = document.getElementById('prev-btn');
  const nextBtn = document.getElementById('next-btn');
  prevBtn.disabled = idx <= 0;
  nextBtn.disabled = idx >= allDates.length - 1;
}

function renderPastMode() {
  const widget = document.getElementById('widget');
  widget.classList.toggle('past-mode', !isToday(viewingDate));
}

function renderTodos() {
  const list       = document.getElementById('todo-list');
  const emptyState = document.getElementById('empty-state');
  const countEl    = document.getElementById('task-count');

  list.innerHTML = '';

  const done  = todos.filter(t => t.done).length;
  const total = todos.length;
  countEl.textContent = `${done} / ${total}`;

  if (total === 0) {
    emptyState.classList.add('visible');
    return;
  }
  emptyState.classList.remove('visible');

  todos.forEach(todo => {
    const li = createTodoElement(todo);
    list.appendChild(li);
  });
}

function createTodoElement(todo) {
  const li = document.createElement('li');
  li.className = [
    'todo-item',
    todo.done     ? 'done'     : '',
    todo.priority ? 'priority' : '',
  ].filter(Boolean).join(' ');
  li.dataset.id = todo.id;

  // Checkbox
  const checkbox = document.createElement('input');
  checkbox.type    = 'checkbox';
  checkbox.checked = todo.done;
  checkbox.className = 'todo-checkbox';
  checkbox.setAttribute('aria-label', '완료 표시');
  checkbox.addEventListener('change', () => toggleDone(todo.id));

  // Text (double-click to edit)
  const textEl = document.createElement('span');
  textEl.className = 'todo-text';
  textEl.textContent = todo.text;
  textEl.title = '더블클릭하여 수정';
  textEl.addEventListener('dblclick', () => startEdit(textEl, todo.id));

  // Star / priority button
  const starBtn = document.createElement('button');
  starBtn.className = 'star-btn' + (todo.priority ? ' active' : '');
  starBtn.setAttribute('aria-label', todo.priority ? '우선순위 해제' : '우선순위 설정');
  starBtn.setAttribute('title',       todo.priority ? '우선순위 해제' : '우선순위 설정');
  starBtn.innerHTML = `<span class="star-icon">${todo.priority ? '★' : '☆'}</span>`;
  starBtn.addEventListener('click', () => togglePriority(todo.id));

  // Delete button
  const delBtn = document.createElement('button');
  delBtn.className = 'delete-btn';
  delBtn.textContent = '✕';
  delBtn.setAttribute('aria-label', '삭제');
  delBtn.setAttribute('title', '삭제');
  delBtn.addEventListener('click', () => deleteTodo(todo.id));

  li.append(checkbox, textEl, starBtn, delBtn);
  return li;
}

// ── Inline edit ────────────────────────────────────────────
function startEdit(el, id) {
  el.contentEditable = 'true';
  el.focus();

  // Move cursor to end
  const range = document.createRange();
  const sel   = window.getSelection();
  range.selectNodeContents(el);
  range.collapse(false);
  sel.removeAllRanges();
  sel.addRange(range);

  function commit() {
    el.contentEditable = 'false';
    updateText(id, el.textContent);
    el.removeEventListener('blur',    commit);
    el.removeEventListener('keydown', onKey);
  }

  function onKey(e) {
    if (e.key === 'Enter') { e.preventDefault(); commit(); }
    if (e.key === 'Escape') {
      el.contentEditable = 'false';
      // Revert
      const original = todos.find(t => t.id === id);
      if (original) el.textContent = original.text;
      el.removeEventListener('blur',    commit);
      el.removeEventListener('keydown', onKey);
    }
  }

  el.addEventListener('blur',    commit);
  el.addEventListener('keydown', onKey);
}

// ── Input / Add ────────────────────────────────────────────
function setupAddTodo() {
  const input  = document.getElementById('new-todo-input');
  const addBtn = document.getElementById('add-btn');

  function submit() {
    if (!isToday(viewingDate)) return;
    addTodo(input.value);
    input.value = '';
    input.focus();
  }

  addBtn.addEventListener('click', submit);
  input.addEventListener('keydown', e => {
    if (e.key === 'Enter') submit();
  });
}

// ── Window controls ────────────────────────────────────────
function setupWindowControls() {
  document.getElementById('close-btn').addEventListener('click', () => {
    window.api.closeWindow();
  });
  document.getElementById('min-btn').addEventListener('click', () => {
    window.api.minimizeWindow();
  });
}

// ── Date navigation ────────────────────────────────────────
function setupNavigation() {
  document.getElementById('prev-btn').addEventListener('click', () => navigate(-1));
  document.getElementById('next-btn').addEventListener('click', () => navigate(+1));
}

// ── Daily auto-reset check ─────────────────────────────────
// Each day the user opens the app they start fresh on today's date.
// Past dates are preserved for browsing but cannot be edited.
function setupDailyReset() {
  // Check every minute if the date has rolled over while the app is open
  setInterval(async () => {
    const newToday = getDateKey(new Date());
    if (newToday !== todayDate && isToday(viewingDate)) {
      // Reload the page so todayDate const updates (simplest approach)
      location.reload();
    }
  }, 60 * 1000);
}

// ── Init ───────────────────────────────────────────────────
async function init() {
  await refreshAllDates();
  await loadDate(todayDate);
  setupAddTodo();
  setupWindowControls();
  setupNavigation();
  setupDailyReset();

  // Focus input on load
  document.getElementById('new-todo-input').focus();
}

document.addEventListener('DOMContentLoaded', init);
