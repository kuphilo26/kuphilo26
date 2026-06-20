## Hi there 👋

<!--
**kuphilo26/kuphilo26** is a ✨ _special_ ✨ repository because its `README.md` (this file) appears on your GitHub profile.

Here are some ideas to get you started:

- 🔭 I’m currently working on ...
- 🌱 I’m currently learning ...
- 👯 I’m looking to collaborate on ...
- 🤔 I’m looking for help with ...
- 💬 Ask me about ...
- 📫 How to reach me: ...
- 😄 Pronouns: ...
- ⚡ Fun fact: ...
-->

npm run deploy

import { useState, useEffect, useCallback } from "react";

// ─── 초기 데이터 ───────────────────────────────────────────────────────────────
const MACHINES = {
  washers: [
    { id: "W1", label: "세탁기 1호" },
    { id: "W2", label: "세탁기 2호" },
    { id: "W3", label: "세탁기 3호" },
    { id: "W4", label: "세탁기 4호" },
    { id: "W5", label: "세탁기 5호" },
    { id: "W6", label: "세탁기 6호" },
    { id: "W7", label: "세탁기 7호" },
    { id: "W8", label: "세탁기 8호" },
  ],
  dryers: [
    { id: "D1", label: "건조기 1호" },
    { id: "D2", label: "건조기 2호" },
    { id: "D3", label: "건조기 3호" },
    { id: "D4", label: "건조기 4호" },
    { id: "D5", label: "건조기 5호" },
    { id: "D6", label: "건조기 6호" },
    { id: "D7", label: "건조기 7호" },
    { id: "D8", label: "건조기 8호" },
  ],
};

const DEMO_USERS = [
  { id: "2026130124", password: "pass1", name: "신현", room: "302호", phone: "010-1234-5678" },
  { id: "2026000001", password: "pass2", name: "김철수", room: "115호", phone: "010-9999-1111" },
  { id: "2026000002", password: "pass3", name: "이영희", room: "207호", phone: "010-8888-2222" },
];

const HOURS = Array.from({ length: 16 }, (_, i) => i + 7); // 07:00 ~ 22:00

function pad(n) { return String(n).padStart(2, "0"); }
function timeLabel(h) { return `${pad(h)}:00`; }
function nowHour() { return new Date().getHours(); }

// ─── 기계 상태 초기화 ──────────────────────────────────────────────────────────
function initMachineState() {
  const state = {};
  [...MACHINES.washers, ...MACHINES.dryers].forEach(m => {
    state[m.id] = {
      reservations: {},    // { hour: { userId, room } }
      running: false,
      runningUntil: null,
      broken: false,
    };
  });
  // 데모용 기존 예약
  state["W1"].reservations[9]  = { userId: "2026000001", room: "115호", name: "김철수" };
  state["W2"].reservations[13] = { userId: "2026000002", room: "207호", name: "이영희" };
  state["D1"].reservations[10] = { userId: "2026000001", room: "115호", name: "김철수" };
  return state;
}

// ─── 색상 토큰 ─────────────────────────────────────────────────────────────────
const C = {
  bg:      "#F0F4FF",
  surface: "#FFFFFF",
  card:    "#FAFBFF",
  border:  "#DDE3F0",
  accent:  "#3B5BDB",
  accentL: "#E8ECFF",
  green:   "#2F9E44",
  greenL:  "#D3F9D8",
  red:     "#C92A2A",
  redL:    "#FFE3E3",
  yellow:  "#E67700",
  yellowL: "#FFF3BF",
  gray:    "#868E96",
  text:    "#1A1B2E",
  sub:     "#495057",
};

// ─── 공통 스타일 ───────────────────────────────────────────────────────────────
const S = {
  btn: (color = C.accent, bg = C.accentL) => ({
    background: bg, color,
    border: `1.5px solid ${color}`, borderRadius: 8,
    padding: "6px 14px", cursor: "pointer", fontSize: 13,
    fontWeight: 600, transition: "all .15s",
  }),
  card: {
    background: C.surface, borderRadius: 14,
    border: `1px solid ${C.border}`,
    boxShadow: "0 2px 12px rgba(59,91,219,.07)",
    padding: "20px 24px", marginBottom: 16,
  },
  tag: (bg, color) => ({
    background: bg, color, fontSize: 11, fontWeight: 700,
    padding: "2px 8px", borderRadius: 20, display: "inline-block",
  }),
  input: {
    border: `1.5px solid ${C.border}`, borderRadius: 8,
    padding: "8px 12px", fontSize: 14, width: "100%",
    outline: "none", background: C.card, color: C.text,
    boxSizing: "border-box",
  },
};

// ══════════════════════════════════════════════════════════════════════════════
// 로그인 화면
// ══════════════════════════════════════════════════════════════════════════════
function LoginScreen({ onLogin }) {
  const [id, setId] = useState("2026130124");
  const [pw, setPw] = useState("pass1");
  const [err, setErr] = useState("");

  function handleLogin() {
    const user = DEMO_USERS.find(u => u.id === id && u.password === pw);
    if (!user) { setErr("학번 또는 비밀번호가 올바르지 않습니다."); return; }
    onLogin(user);
  }

  return (
    <div style={{
      minHeight: "100vh", background: `linear-gradient(135deg, #3B5BDB 0%, #5C7CFA 100%)`,
      display: "flex", alignItems: "center", justifyContent: "center",
    }}>
      <div style={{
        background: C.surface, borderRadius: 20, padding: "40px 36px",
        width: 360, boxShadow: "0 20px 60px rgba(0,0,0,.2)",
      }}>
        {/* 로고 */}
        <div style={{ textAlign: "center", marginBottom: 28 }}>
          <div style={{
            width: 56, height: 56, borderRadius: 16,
            background: C.accentL, margin: "0 auto 14px",
            display: "flex", alignItems: "center", justifyContent: "center",
            fontSize: 28,
          }}>🧺</div>
          <div style={{ fontSize: 22, fontWeight: 800, color: C.text }}>고려대 기숙사</div>
          <div style={{ fontSize: 14, color: C.gray, marginTop: 4 }}>세탁실 예약 시스템</div>
        </div>

        <div style={{ marginBottom: 14 }}>
          <label style={{ fontSize: 12, fontWeight: 600, color: C.sub }}>학번</label>
          <input style={{ ...S.input, marginTop: 4 }}
            value={id} onChange={e => setId(e.target.value)}
            placeholder="학번 입력" onKeyDown={e => e.key === "Enter" && handleLogin()} />
        </div>
        <div style={{ marginBottom: 20 }}>
          <label style={{ fontSize: 12, fontWeight: 600, color: C.sub }}>비밀번호</label>
          <input style={{ ...S.input, marginTop: 4 }}
            type="password" value={pw} onChange={e => setPw(e.target.value)}
            placeholder="비밀번호 입력" onKeyDown={e => e.key === "Enter" && handleLogin()} />
        </div>

        {err && <div style={{ ...S.tag(C.redL, C.red), marginBottom: 14, width: "100%", textAlign: "center", padding: "8px 0" }}>{err}</div>}

        <button
          onClick={handleLogin}
          style={{
            width: "100%", background: C.accent, color: "#fff",
            border: "none", borderRadius: 10, padding: "12px 0",
            fontSize: 15, fontWeight: 700, cursor: "pointer",
          }}
        >로그인</button>

        <div style={{ marginTop: 16, fontSize: 11, color: C.gray, textAlign: "center" }}>
          데모 계정: 학번 2026130124 / 비밀번호 pass1
        </div>
      </div>
    </div>
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// 메인 앱
// ══════════════════════════════════════════════════════════════════════════════
export default function App() {
  const [user, setUser] = useState(null);
  const [tab, setTab] = useState("washer");
  const [machines, setMachines] = useState(initMachineState);
  const [myWeekCount, setMyWeekCount] = useState({ washer: 0, dryer: 0 });
  const [myReportCount, setMyReportCount] = useState(0);
  const [msgTarget, setMsgTarget] = useState(null); // { machineId, hour, ownerRoom }
  const [msgText, setMsgText] = useState("");
  const [messages, setMessages] = useState([]); // { to, from, text, time }
  const [toast, setToast] = useState(null);
  const [reportTarget, setReportTarget] = useState(null);
  const [reportReason, setReportReason] = useState("");
  const [myInbox, setMyInbox] = useState([]);
  const [showInbox, setShowInbox] = useState(false);

  // 건조기 running 타이머
  useEffect(() => {
    const interval = setInterval(() => {
      setMachines(prev => {
        const next = { ...prev };
        MACHINES.dryers.forEach(d => {
          const m = next[d.id];
          if (m.running && m.runningUntil && Date.now() > m.runningUntil) {
            next[d.id] = { ...m, running: false, runningUntil: null };
          }
        });
        return next;
      });
    }, 5000);
    return () => clearInterval(interval);
  }, []);

  function showToast(msg, type = "success") {
    setToast({ msg, type });
    setTimeout(() => setToast(null), 2500);
  }

  function reserve(machineId, hour, type) {
    const countKey = type === "washer" ? "washer" : "dryer";
    if (myWeekCount[countKey] >= 3) {
      showToast("이번 주 예약 횟수(3회)를 초과했습니다.", "error"); return;
    }
    const m = machines[machineId];
    if (m.reservations[hour]) {
      showToast("이미 예약된 시간입니다.", "error"); return;
    }
    if (m.broken) {
      showToast("고장 신고된 기계입니다.", "error"); return;
    }
    setMachines(prev => ({
      ...prev,
      [machineId]: {
        ...prev[machineId],
        reservations: {
          ...prev[machineId].reservations,
          [hour]: { userId: user.id, room: user.room, name: user.name },
        },
      },
    }));
    setMyWeekCount(prev => ({ ...prev, [countKey]: prev[countKey] + 1 }));
    showToast(`${timeLabel(hour)} ${type === "washer" ? "세탁기" : "건조기"} 예약 완료!`);
  }

  function cancelReserve(machineId, hour, type) {
    const m = machines[machineId];
    const res = m.reservations[hour];
    if (!res || res.userId !== user.id) return;
    const updated = { ...m.reservations };
    delete updated[hour];
    setMachines(prev => ({
      ...prev,
      [machineId]: { ...prev[machineId], reservations: updated },
    }));
    const countKey = type === "washer" ? "washer" : "dryer";
    setMyWeekCount(prev => ({ ...prev, [countKey]: Math.max(0, prev[countKey] - 1) }));
    showToast("예약이 취소되었습니다.", "info");
  }

  // 건조기 시작 버튼
  function startDryer(machineId) {
    setMachines(prev => ({
      ...prev,
      [machineId]: {
        ...prev[machineId],
        running: true,
        runningUntil: Date.now() + 50 * 60 * 1000,
      },
    }));
    showToast("건조 시작! 50분 후 자동 해제됩니다.");
  }

  function sendMessage() {
    if (!msgText.trim()) return;
    const newMsg = {
      to: msgTarget.ownerRoom,
      from: user.room,
      fromName: user.name,
      text: msgText,
      machine: msgTarget.machineId,
      time: new Date().toLocaleTimeString("ko-KR", { hour: "2-digit", minute: "2-digit" }),
    };
    setMessages(prev => [...prev, newMsg]);
    setMyInbox(prev => [...prev, newMsg]);
    setMsgTarget(null);
    setMsgText("");
    showToast(`${msgTarget.ownerRoom}에 메시지를 전송했습니다.`);
  }

  function reportMachine(machineId) {
    if (myReportCount >= 3) {
      showToast("이번 주 신고 횟수(3회)를 초과했습니다.", "error"); return;
    }
    if (!reportReason.trim()) { showToast("사유를 입력해주세요.", "error"); return; }
    setMachines(prev => ({
      ...prev,
      [machineId]: { ...prev[machineId], broken: true },
    }));
    setMyReportCount(prev => prev + 1);
    // 해당 기계 예약 취소 & 횟수 복구
    const m = machines[machineId];
    let washerRestore = 0, dryerRestore = 0;
    Object.values(m.reservations).forEach(r => {
      if (r.userId === user.id) {
        if (machineId.startsWith("W")) washerRestore++;
        else dryerRestore++;
      }
    });
    setMyWeekCount(prev => ({
      washer: Math.max(0, prev.washer - washerRestore),
      dryer: Math.max(0, prev.dryer - dryerRestore),
    }));
    setReportTarget(null);
    setReportReason("");
    showToast("고장 신고 완료. 예약 횟수가 복구되었습니다.", "info");
  }

  if (!user) return <LoginScreen onLogin={setUser} />;

  const inboxForMe = messages.filter(m => m.to === user.room);
  const unread = inboxForMe.length;

  return (
    <div style={{ minHeight: "100vh", background: C.bg, fontFamily: "'Pretendard', 'Apple SD Gothic Neo', sans-serif" }}>
      {/* 상단 바 */}
      <div style={{
        background: C.accent, color: "#fff", padding: "14px 24px",
        display: "flex", alignItems: "center", justifyContent: "space-between",
        position: "sticky", top: 0, zIndex: 100,
        boxShadow: "0 2px 12px rgba(59,91,219,.3)",
      }}>
        <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
          <span style={{ fontSize: 22 }}>🧺</span>
          <div>
            <div style={{ fontWeight: 800, fontSize: 15 }}>기숙사 세탁실 예약</div>
            <div style={{ fontSize: 11, opacity: .8 }}>{user.name} · {user.room}</div>
          </div>
        </div>
        <div style={{ display: "flex", gap: 8, alignItems: "center" }}>
          <button onClick={() => setShowInbox(v => !v)}
            style={{ ...S.btn("#fff", "rgba(255,255,255,.2)"), position: "relative", border: "1.5px solid rgba(255,255,255,.4)" }}>
            📬 쪽지함
            {unread > 0 && (
              <span style={{
                position: "absolute", top: -6, right: -6,
                background: C.red, color: "#fff",
                borderRadius: "50%", width: 18, height: 18,
                fontSize: 11, fontWeight: 800,
                display: "flex", alignItems: "center", justifyContent: "center",
              }}>{unread}</span>
            )}
          </button>
          <button onClick={() => setUser(null)}
            style={{ ...S.btn("#fff", "rgba(255,255,255,.15)"), border: "1.5px solid rgba(255,255,255,.4)" }}>
            로그아웃
          </button>
        </div>
      </div>

      <div style={{ maxWidth: 900, margin: "0 auto", padding: "20px 16px" }}>
        {/* 내 예약 현황 요약 */}
        <div style={{
          display: "grid", gridTemplateColumns: "1fr 1fr 1fr", gap: 12, marginBottom: 20,
        }}>
          {[
            { label: "세탁기 이용 횟수", val: `${myWeekCount.washer} / 3회`, icon: "🌀", color: C.accent },
            { label: "건조기 이용 횟수", val: `${myWeekCount.dryer} / 3회`, icon: "♨️", color: C.green },
            { label: "고장 신고 횟수", val: `${myReportCount} / 3회`, icon: "🔧", color: C.yellow },
          ].map(item => (
            <div key={item.label} style={{
              background: C.surface, borderRadius: 12,
              border: `1px solid ${C.border}`,
              padding: "14px 16px",
              boxShadow: "0 2px 8px rgba(0,0,0,.04)",
            }}>
              <div style={{ fontSize: 20, marginBottom: 4 }}>{item.icon}</div>
              <div style={{ fontSize: 18, fontWeight: 800, color: item.color }}>{item.val}</div>
              <div style={{ fontSize: 11, color: C.gray }}>{item.label} (이번 주)</div>
            </div>
          ))}
        </div>

        {/* 탭 */}
        <div style={{ display: "flex", gap: 8, marginBottom: 20 }}>
          {[
            { key: "washer", label: "🌀 세탁기 예약" },
            { key: "dryer", label: "♨️ 건조기 예약" },
          ].map(t => (
            <button key={t.key} onClick={() => setTab(t.key)}
              style={{
                padding: "10px 22px", borderRadius: 10, border: "none", cursor: "pointer",
                fontSize: 14, fontWeight: 700,
                background: tab === t.key ? C.accent : C.surface,
                color: tab === t.key ? "#fff" : C.sub,
                boxShadow: tab === t.key ? "0 4px 12px rgba(59,91,219,.3)" : "none",
                transition: "all .15s",
              }}>
              {t.label}
            </button>
          ))}
        </div>

        {/* 세탁기 / 건조기 패널 */}
        {tab === "washer" && (
          <MachinePanel
            machines={MACHINES.washers}
            machineStates={machines}
            type="washer"
            user={user}
            onReserve={reserve}
            onCancel={cancelReserve}
            onMessage={(machineId, hour, ownerRoom) => setMsgTarget({ machineId, hour, ownerRoom })}
            onReport={(machineId) => setReportTarget(machineId)}
          />
        )}
        {tab === "dryer" && (
          <MachinePanel
            machines={MACHINES.dryers}
            machineStates={machines}
            type="dryer"
            user={user}
            onReserve={reserve}
            onCancel={cancelReserve}
            onMessage={(machineId, hour, ownerRoom) => setMsgTarget({ machineId, hour, ownerRoom })}
            onReport={(machineId) => setReportTarget(machineId)}
            onStartDryer={startDryer}
          />
        )}
      </div>

      {/* 쪽지함 모달 */}
      {showInbox && (
        <Modal title={`📬 받은 쪽지 (${inboxForMe.length})`} onClose={() => setShowInbox(false)}>
          {inboxForMe.length === 0
            ? <div style={{ color: C.gray, fontSize: 14, textAlign: "center", padding: 20 }}>받은 쪽지가 없습니다.</div>
            : inboxForMe.map((m, i) => (
              <div key={i} style={{ ...S.card, marginBottom: 10, padding: "14px 16px" }}>
                <div style={{ display: "flex", justifyContent: "space-between", marginBottom: 6 }}>
                  <span style={{ fontWeight: 700, fontSize: 13, color: C.accent }}>{m.fromName} ({m.from})</span>
                  <span style={{ fontSize: 11, color: C.gray }}>{m.time}</span>
                </div>
                <div style={{ fontSize: 13, color: C.text }}>{m.text}</div>
                <div style={{ fontSize: 11, color: C.gray, marginTop: 4 }}>기계: {m.machine}</div>
              </div>
            ))
          }
        </Modal>
      )}

      {/* 메시지 전송 모달 */}
      {msgTarget && (
        <Modal title="💬 이용자에게 메시지 전송" onClose={() => setMsgTarget(null)}>
          <div style={{ fontSize: 13, color: C.sub, marginBottom: 12 }}>
            수신자: <strong>{msgTarget.ownerRoom}</strong> ({msgTarget.machineId})
          </div>
          <textarea
            value={msgText} onChange={e => setMsgText(e.target.value)}
            placeholder="메시지를 입력하세요..."
            style={{
              ...S.input, height: 90, resize: "vertical", fontFamily: "inherit",
            }}
          />
          <button onClick={sendMessage}
            style={{
              width: "100%", marginTop: 12, background: C.accent, color: "#fff",
              border: "none", borderRadius: 8, padding: "10px 0", fontSize: 14, fontWeight: 700, cursor: "pointer",
            }}>
            전송
          </button>
        </Modal>
      )}

      {/* 고장 신고 모달 */}
      {reportTarget && (
        <Modal title="🔧 고장 신고" onClose={() => setReportTarget(null)}>
          <div style={{ fontSize: 13, color: C.sub, marginBottom: 12 }}>
            기계: <strong>{reportTarget}</strong>
          </div>
          <textarea
            value={reportReason} onChange={e => setReportReason(e.target.value)}
            placeholder="고장 사유를 입력하세요..."
            style={{ ...S.input, height: 80, resize: "vertical", fontFamily: "inherit" }}
          />
          <button onClick={() => reportMachine(reportTarget)}
            style={{
              width: "100%", marginTop: 12, background: C.red, color: "#fff",
              border: "none", borderRadius: 8, padding: "10px 0", fontSize: 14, fontWeight: 700, cursor: "pointer",
            }}>
            신고 제출
          </button>
        </Modal>
      )}

      {/* 토스트 */}
      {toast && (
        <div style={{
          position: "fixed", bottom: 28, left: "50%", transform: "translateX(-50%)",
          background: toast.type === "error" ? C.red : toast.type === "info" ? C.yellow : C.green,
          color: "#fff", padding: "12px 24px", borderRadius: 40,
          fontWeight: 700, fontSize: 14,
          boxShadow: "0 8px 24px rgba(0,0,0,.2)", zIndex: 9999,
          animation: "fadeIn .2s",
        }}>
          {toast.msg}
        </div>
      )}

      <style>{`
        @keyframes fadeIn { from { opacity: 0; transform: translateX(-50%) translateY(10px); } to { opacity: 1; transform: translateX(-50%) translateY(0); } }
        * { box-sizing: border-box; }
        button:hover { filter: brightness(1.08); }
      `}</style>
    </div>
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// 기계 패널 (세탁기 / 건조기 공통)
// ══════════════════════════════════════════════════════════════════════════════
function MachinePanel({ machines, machineStates, type, user, onReserve, onCancel, onMessage, onReport, onStartDryer }) {
  const isDryer = type === "dryer";

  return (
    <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(340px, 1fr))", gap: 16 }}>
      {machines.map(m => {
        const state = machineStates[m.id];
        return (
          <MachineCard
            key={m.id}
            machine={m}
            state={state}
            isDryer={isDryer}
            user={user}
            onReserve={(hour) => onReserve(m.id, hour, type)}
            onCancel={(hour) => onCancel(m.id, hour, type)}
            onMessage={(hour, room) => onMessage(m.id, hour, room)}
            onReport={() => onReport(m.id)}
            onStartDryer={() => onStartDryer && onStartDryer(m.id)}
          />
        );
      })}
    </div>
  );
}

// ──────────────────────────────────────────────────────────────────────────────
// 개별 기계 카드
// ──────────────────────────────────────────────────────────────────────────────
function MachineCard({ machine, state, isDryer, user, onReserve, onCancel, onMessage, onReport, onStartDryer }) {
  const { reservations, running, runningUntil, broken } = state;
  const current = nowHour();

  // 내 예약이 있는지
  const myReservations = Object.entries(reservations).filter(([, r]) => r.userId === user.id);

  // 현재 사용 중인 방
  const currentUser = reservations[current];

  return (
    <div style={{
      ...S.card, padding: 0, overflow: "hidden",
      border: broken ? `2px solid ${C.red}` : `1px solid ${C.border}`,
    }}>
      {/* 카드 헤더 */}
      <div style={{
        padding: "14px 18px",
        background: broken ? C.redL : running ? C.greenL : C.accentL,
        borderBottom: `1px solid ${C.border}`,
        display: "flex", justifyContent: "space-between", alignItems: "center",
      }}>
        <div style={{ fontWeight: 800, fontSize: 16, color: C.text }}>{machine.label}</div>
        <div style={{ display: "flex", gap: 6 }}>
          {broken && <span style={S.tag(C.redL, C.red)}>⚠ 고장</span>}
          {running && !broken && <span style={S.tag(C.greenL, C.green)}>● 가동 중</span>}
          {!running && !broken && currentUser
            ? <span style={S.tag(C.yellowL, C.yellow)}>사용 중 ({currentUser.room})</span>
            : !running && !broken && <span style={S.tag(C.accentL, C.accent)}>사용 가능</span>}
        </div>
      </div>

      {/* 건조기 running 정보 */}
      {isDryer && running && runningUntil && (
        <div style={{ padding: "8px 18px", background: C.greenL, fontSize: 12, color: C.green, fontWeight: 600 }}>
          ⏱ 종료 예정: {new Date(runningUntil).toLocaleTimeString("ko-KR", { hour: "2-digit", minute: "2-digit" })}
        </div>
      )}

      {/* 이용자에게 메시지 (현재 사용 중이고 내가 아닐 때) */}
      {currentUser && currentUser.userId !== user.id && (
        <div style={{ padding: "8px 18px 0", display: "flex", gap: 8 }}>
          <button onClick={() => onMessage(current, currentUser.room)}
            style={{ ...S.btn(C.accent, C.accentL), fontSize: 12 }}>
            💬 이용자에게 쪽지
          </button>
          {!broken && (
            <button onClick={onReport}
              style={{ ...S.btn(C.red, C.redL), fontSize: 12 }}>
              🔧 고장 신고
            </button>
          )}
        </div>
      )}

      {/* 시간대별 예약 현황 */}
      <div style={{ padding: "14px 18px" }}>
        <div style={{ fontSize: 12, fontWeight: 700, color: C.sub, marginBottom: 8 }}>
          시간대별 예약 현황
        </div>
        <div style={{ display: "flex", flexWrap: "wrap", gap: 5 }}>
          {HOURS.map(h => {
            const res = reservations[h];
            const isMe = res?.userId === user.id;
            const isCurrent = h === current;
            const isPast = h < current;

            let bg = C.bg, color = C.sub, label = timeLabel(h), cursor = "pointer";
            if (isPast) { bg = "#E9ECF0"; color = C.gray; cursor = "default"; }
            else if (isMe) { bg = C.accentL; color = C.accent; }
            else if (res) { bg = C.yellowL; color = C.yellow; cursor = "default"; }
            if (isCurrent) { bg = C.accent; color = "#fff"; }

            return (
              <div key={h}
                title={res ? `${res.room} 예약` : "예약 가능"}
                onClick={() => {
                  if (isPast || broken) return;
                  if (isMe) onCancel(h);
                  else if (!res) onReserve(h);
                }}
                style={{
                  width: 52, height: 42,
                  background: bg, color,
                  borderRadius: 8,
                  display: "flex", flexDirection: "column",
                  alignItems: "center", justifyContent: "center",
                  fontSize: 10, fontWeight: isMe || isCurrent ? 700 : 500,
                  cursor,
                  border: isMe ? `1.5px solid ${C.accent}` : isCurrent ? `1.5px solid ${C.accent}` : `1px solid ${C.border}`,
                  transition: "all .12s",
                  userSelect: "none",
                }}>
                <div>{label}</div>
                {res && <div style={{ fontSize: 9, marginTop: 1, opacity: .8 }}>{isMe ? "내 예약" : res.room}</div>}
                {!res && !isPast && <div style={{ fontSize: 9, color: C.green, marginTop: 1 }}>예약</div>}
              </div>
            );
          })}
        </div>
        <div style={{ marginTop: 8, fontSize: 11, color: C.gray }}>
          클릭하여 예약 · 내 예약 클릭 시 취소
        </div>
      </div>

      {/* 건조기 시작 버튼 */}
      {isDryer && myReservations.some(([h]) => Number(h) === current) && !running && (
        <div style={{ padding: "0 18px 14px" }}>
          <button onClick={onStartDryer}
            style={{
              ...S.btn(C.green, C.greenL),
              width: "100%", padding: "10px 0", fontSize: 13,
            }}>
            ▶ 건조 시작 (50분 가동)
          </button>
        </div>
      )}

      {/* 내 예약 목록 */}
      {myReservations.length > 0 && (
        <div style={{
          margin: "0 18px 14px",
          background: C.accentL, borderRadius: 8, padding: "8px 12px",
        }}>
          <div style={{ fontSize: 11, fontWeight: 700, color: C.accent, marginBottom: 4 }}>내 예약</div>
          {myReservations.map(([h]) => (
            <div key={h} style={{ fontSize: 12, color: C.accent, display: "flex", justifyContent: "space-between" }}>
              <span>{timeLabel(Number(h))}</span>
              <button onClick={() => onCancel(Number(h))}
                style={{ background: "none", border: "none", color: C.red, cursor: "pointer", fontSize: 11, fontWeight: 700 }}>
                취소
              </button>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

// ──────────────────────────────────────────────────────────────────────────────
// 모달
// ──────────────────────────────────────────────────────────────────────────────
function Modal({ title, onClose, children }) {
  return (
    <div style={{
      position: "fixed", inset: 0, background: "rgba(0,0,0,.45)",
      display: "flex", alignItems: "center", justifyContent: "center",
      zIndex: 1000, padding: 16,
    }} onClick={e => e.target === e.currentTarget && onClose()}>
      <div style={{
        background: C.surface, borderRadius: 16, width: "100%", maxWidth: 420,
        boxShadow: "0 20px 60px rgba(0,0,0,.3)",
        maxHeight: "80vh", overflow: "auto",
      }}>
        <div style={{
          padding: "16px 20px", borderBottom: `1px solid ${C.border}`,
          display: "flex", justifyContent: "space-between", alignItems: "center",
          position: "sticky", top: 0, background: C.surface,
        }}>
          <div style={{ fontWeight: 800, fontSize: 15, color: C.text }}>{title}</div>
          <button onClick={onClose}
            style={{ background: "none", border: "none", fontSize: 18, cursor: "pointer", color: C.gray }}>✕</button>
        </div>
        <div style={{ padding: "16px 20px" }}>{children}</div>
      </div>
    </div>
  );
}

