<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>고려대 기숙사 세탁실 예약</title>
<script src="https://cdnjs.cloudflare.com/ajax/libs/react/18.2.0/umd/react.production.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/react-dom/18.2.0/umd/react-dom.production.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/babel-standalone/7.23.2/babel.min.js"></script>
<style>
  *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
  body { font-family: 'Apple SD Gothic Neo', 'Pretendard', 'Noto Sans KR', sans-serif; background: #F0F4FF; }
  button { cursor: pointer; font-family: inherit; }
  button:hover { filter: brightness(1.07); }
  textarea, input { font-family: inherit; }
  ::-webkit-scrollbar { width: 6px; height: 6px; }
  ::-webkit-scrollbar-track { background: #F0F4FF; }
  ::-webkit-scrollbar-thumb { background: #c0c8e8; border-radius: 4px; }
  @keyframes fadeUp {
    from { opacity: 0; transform: translateX(-50%) translateY(10px); }
    to   { opacity: 1; transform: translateX(-50%) translateY(0); }
  }
  @keyframes modalIn {
    from { opacity: 0; transform: scale(.96); }
    to   { opacity: 1; transform: scale(1); }
  }
</style>
</head>
<body>
<div id="root"></div>

<script type="text/babel">
const { useState, useEffect, useCallback, useRef } = React;

// ─── 데이터 ────────────────────────────────────────────────────────────────────
const MACHINES = {
  washers: Array.from({length:8},(_,i)=>({id:`W${i+1}`,label:`세탁기 ${i+1}호`})),
  dryers:  Array.from({length:8},(_,i)=>({id:`D${i+1}`,label:`건조기 ${i+1}호`})),
};

const DEMO_USERS = [
  {id:"2026130124", password:"pass1", name:"신현",  room:"302호", phone:"010-1234-5678"},
  {id:"2026000001", password:"pass2", name:"김철수", room:"115호", phone:"010-9999-1111"},
  {id:"2026000002", password:"pass3", name:"이영희", room:"207호", phone:"010-8888-2222"},
];

const HOURS = Array.from({length:16},(_,i)=>i+7); // 07~22

function pad(n){ return String(n).padStart(2,"0"); }
function tLabel(h){ return `${pad(h)}:00`; }
function nowHour(){ return new Date().getHours(); }

// ─── 색상 ──────────────────────────────────────────────────────────────────────
const C = {
  bg:"#F0F4FF", surface:"#FFFFFF", card:"#FAFBFF", border:"#DDE3F0",
  accent:"#3B5BDB", accentL:"#E8ECFF",
  green:"#2F9E44",  greenL:"#D3F9D8",
  red:"#C92A2A",    redL:"#FFE3E3",
  yellow:"#E67700", yellowL:"#FFF3BF",
  gray:"#868E96",   text:"#1A1B2E", sub:"#495057",
};

// ─── 기계 초기화 ────────────────────────────────────────────────────────────────
function initMachines(){
  const s = {};
  [...MACHINES.washers,...MACHINES.dryers].forEach(m=>{
    s[m.id]={reservations:{}, running:false, runningUntil:null, broken:false};
  });
  s["W1"].reservations[9]  = {userId:"2026000001",room:"115호",name:"김철수"};
  s["W2"].reservations[13] = {userId:"2026000002",room:"207호",name:"이영희"};
  s["D1"].reservations[10] = {userId:"2026000001",room:"115호",name:"김철수"};
  return s;
}

// ══════════════════════════════════════════════════════════════════════════════
// 로그인
// ══════════════════════════════════════════════════════════════════════════════
function Login({onLogin}){
  const [id,setId]=useState("2026130124");
  const [pw,setPw]=useState("pass1");
  const [err,setErr]=useState("");

  function submit(){
    const u=DEMO_USERS.find(u=>u.id===id&&u.password===pw);
    if(!u){setErr("학번 또는 비밀번호를 확인해주세요.");return;}
    onLogin(u);
  }

  const inp={
    border:`1.5px solid ${C.border}`,borderRadius:8,padding:"9px 12px",
    fontSize:14,width:"100%",outline:"none",background:C.card,color:C.text,
    marginTop:4,
  };

  return (
    <div style={{minHeight:"100vh",background:"linear-gradient(135deg,#3B5BDB,#5C7CFA)",
      display:"flex",alignItems:"center",justifyContent:"center",padding:16}}>
      <div style={{background:C.surface,borderRadius:20,padding:"40px 36px",
        width:"100%",maxWidth:360,boxShadow:"0 20px 60px rgba(0,0,0,.22)"}}>
        <div style={{textAlign:"center",marginBottom:28}}>
          <div style={{width:56,height:56,borderRadius:16,background:C.accentL,
            margin:"0 auto 12px",fontSize:28,display:"flex",alignItems:"center",justifyContent:"center"}}>🧺</div>
          <div style={{fontSize:22,fontWeight:800,color:C.text}}>고려대 기숙사</div>
          <div style={{fontSize:13,color:C.gray,marginTop:3}}>세탁실 예약 시스템</div>
        </div>

        <label style={{fontSize:12,fontWeight:600,color:C.sub}}>학번</label>
        <input style={inp} value={id} onChange={e=>setId(e.target.value)}
          placeholder="학번 입력" onKeyDown={e=>e.key==="Enter"&&submit()} />

        <label style={{fontSize:12,fontWeight:600,color:C.sub,display:"block",marginTop:12}}>비밀번호</label>
        <input style={inp} type="password" value={pw} onChange={e=>setPw(e.target.value)}
          placeholder="비밀번호 입력" onKeyDown={e=>e.key==="Enter"&&submit()} />

        {err&&<div style={{background:C.redL,color:C.red,fontSize:12,fontWeight:600,
          borderRadius:8,padding:"8px 12px",marginTop:12,textAlign:"center"}}>{err}</div>}

        <button onClick={submit} style={{width:"100%",marginTop:20,background:C.accent,
          color:"#fff",border:"none",borderRadius:10,padding:"13px 0",fontSize:15,fontWeight:700}}>
          로그인
        </button>
        <div style={{marginTop:14,fontSize:11,color:C.gray,textAlign:"center"}}>
          데모 계정: 2026130124 / pass1
        </div>
      </div>
    </div>
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// 모달
// ══════════════════════════════════════════════════════════════════════════════
function Modal({title,onClose,children}){
  return (
    <div onClick={e=>e.target===e.currentTarget&&onClose()}
      style={{position:"fixed",inset:0,background:"rgba(0,0,0,.45)",
        display:"flex",alignItems:"center",justifyContent:"center",zIndex:1000,padding:16}}>
      <div style={{background:C.surface,borderRadius:16,width:"100%",maxWidth:440,
        boxShadow:"0 20px 60px rgba(0,0,0,.3)",maxHeight:"80vh",overflow:"auto",
        animation:"modalIn .18s ease"}}>
        <div style={{padding:"15px 20px",borderBottom:`1px solid ${C.border}`,
          display:"flex",justifyContent:"space-between",alignItems:"center",
          position:"sticky",top:0,background:C.surface,zIndex:1}}>
          <span style={{fontWeight:800,fontSize:15,color:C.text}}>{title}</span>
          <button onClick={onClose} style={{background:"none",border:"none",
            fontSize:20,color:C.gray,lineHeight:1}}>✕</button>
        </div>
        <div style={{padding:"16px 20px"}}>{children}</div>
      </div>
    </div>
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// 기계 카드
// ══════════════════════════════════════════════════════════════════════════════
function MachineCard({machine,state,isDryer,user,onReserve,onCancel,onMsg,onReport,onStartDryer}){
  const {reservations,running,runningUntil,broken}=state;
  const cur=nowHour();
  const myRes=Object.entries(reservations).filter(([,r])=>r.userId===user.id);
  const curUser=reservations[cur];

  const statusLabel = broken
    ? <span style={tag(C.redL,C.red)}>⚠ 고장</span>
    : running
      ? <span style={tag(C.greenL,C.green)}>● 가동 중</span>
      : curUser
        ? <span style={tag(C.yellowL,C.yellow)}>사용 중 ({curUser.room})</span>
        : <span style={tag(C.accentL,C.accent)}>사용 가능</span>;

  const headerBg = broken?C.redL : running?C.greenL : C.accentL;

  return (
    <div style={{background:C.surface,borderRadius:14,overflow:"hidden",
      border:broken?`2px solid ${C.red}`:`1px solid ${C.border}`,
      boxShadow:"0 2px 12px rgba(59,91,219,.07)"}}>

      {/* 헤더 */}
      <div style={{background:headerBg,padding:"13px 16px",
        display:"flex",justifyContent:"space-between",alignItems:"center",
        borderBottom:`1px solid ${C.border}`}}>
        <span style={{fontWeight:800,fontSize:15,color:C.text}}>{machine.label}</span>
        <div style={{display:"flex",gap:5}}>{statusLabel}</div>
      </div>

      {/* 건조기 종료 예정 */}
      {isDryer&&running&&runningUntil&&(
        <div style={{background:C.greenL,padding:"6px 16px",fontSize:12,color:C.green,fontWeight:600}}>
          ⏱ 종료 예정: {new Date(runningUntil).toLocaleTimeString("ko-KR",{hour:"2-digit",minute:"2-digit"})}
        </div>
      )}

      {/* 쪽지·신고 버튼 */}
      {curUser&&curUser.userId!==user.id&&(
        <div style={{padding:"8px 16px 0",display:"flex",gap:6}}>
          <button onClick={()=>onMsg(cur,curUser.room)}
            style={btn(C.accent,C.accentL,12)}>💬 이용자에게 쪽지</button>
          {!broken&&<button onClick={onReport} style={btn(C.red,C.redL,12)}>🔧 고장 신고</button>}
        </div>
      )}

      {/* 시간 슬롯 */}
      <div style={{padding:"13px 16px"}}>
        <div style={{fontSize:11,fontWeight:700,color:C.sub,marginBottom:7}}>시간대별 예약 현황</div>
        <div style={{display:"flex",flexWrap:"wrap",gap:4}}>
          {HOURS.map(h=>{
            const res=reservations[h];
            const isMe=res?.userId===user.id;
            const isCur=h===cur;
            const isPast=h<cur;
            let bg=C.bg,co=C.sub,cu="pointer";
            if(isPast){bg="#E9ECF0";co=C.gray;cu="default";}
            else if(isMe){bg=C.accentL;co=C.accent;}
            else if(res){bg=C.yellowL;co=C.yellow;cu="default";}
            if(isCur){bg=C.accent;co="#fff";}
            return (
              <div key={h}
                title={res?`${res.room} 예약`:"예약 가능"}
                onClick={()=>{
                  if(isPast||broken)return;
                  if(isMe)onCancel(h);
                  else if(!res)onReserve(h);
                }}
                style={{width:50,height:40,background:bg,color:co,borderRadius:7,
                  display:"flex",flexDirection:"column",alignItems:"center",justifyContent:"center",
                  fontSize:10,fontWeight:isMe||isCur?700:500,cursor:cu,userSelect:"none",
                  border:isMe||isCur?`1.5px solid ${C.accent}`:`1px solid ${C.border}`,
                  transition:"all .1s"}}>
                <div>{tLabel(h)}</div>
                {res&&<div style={{fontSize:9,opacity:.85}}>{isMe?"내 예약":res.room}</div>}
                {!res&&!isPast&&<div style={{fontSize:9,color:C.green}}>예약</div>}
              </div>
            );
          })}
        </div>
        <div style={{marginTop:7,fontSize:11,color:C.gray}}>클릭 → 예약 / 내 예약 클릭 → 취소</div>
      </div>

      {/* 건조 시작 버튼 */}
      {isDryer&&myRes.some(([h])=>Number(h)===cur)&&!running&&(
        <div style={{padding:"0 16px 14px"}}>
          <button onClick={onStartDryer}
            style={{...btn(C.green,C.greenL,13),width:"100%",padding:"9px 0"}}>
            ▶ 건조 시작 (50분 가동)
          </button>
        </div>
      )}

      {/* 내 예약 목록 */}
      {myRes.length>0&&(
        <div style={{margin:"0 16px 14px",background:C.accentL,borderRadius:8,padding:"8px 12px"}}>
          <div style={{fontSize:11,fontWeight:700,color:C.accent,marginBottom:4}}>내 예약</div>
          {myRes.map(([h])=>(
            <div key={h} style={{display:"flex",justifyContent:"space-between",alignItems:"center",
              fontSize:12,color:C.accent}}>
              <span>{tLabel(Number(h))}</span>
              <button onClick={()=>onCancel(Number(h))}
                style={{background:"none",border:"none",color:C.red,fontWeight:700,fontSize:11}}>취소</button>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

// ── 스타일 헬퍼 ──────────────────────────────────────────────────────────────
function tag(bg,co){
  return{background:bg,color:co,fontSize:11,fontWeight:700,
    padding:"2px 8px",borderRadius:20,display:"inline-block"};
}
function btn(co,bg,fs=13){
  return{background:bg,color:co,border:`1.5px solid ${co}`,borderRadius:8,
    padding:"6px 13px",fontSize:fs,fontWeight:600,transition:"all .15s"};
}

// ══════════════════════════════════════════════════════════════════════════════
// 메인 앱
// ══════════════════════════════════════════════════════════════════════════════
function App(){
  const [user,setUser]=useState(null);
  const [tab,setTab]=useState("washer");
  const [ms,setMs]=useState(initMachines);
  const [wkCount,setWkCount]=useState({washer:0,dryer:0});
  const [rpCount,setRpCount]=useState(0);
  const [toast,setToast]=useState(null);
  const [msgTarget,setMsgTarget]=useState(null);
  const [msgText,setMsgText]=useState("");
  const [inbox,setInbox]=useState([]);   // 내가 받은 쪽지
  const [showInbox,setShowInbox]=useState(false);
  const [rpTarget,setRpTarget]=useState(null);
  const [rpReason,setRpReason]=useState("");

  // 건조기 자동 해제
  useEffect(()=>{
    const t=setInterval(()=>{
      setMs(prev=>{
        let changed=false;
        const next={...prev};
        MACHINES.dryers.forEach(d=>{
          const m=next[d.id];
          if(m.running&&m.runningUntil&&Date.now()>m.runningUntil){
            next[d.id]={...m,running:false,runningUntil:null};
            changed=true;
          }
        });
        return changed?next:prev;
      });
    },4000);
    return()=>clearInterval(t);
  },[]);

  function showToast(msg,type="ok"){
    setToast({msg,type});
    setTimeout(()=>setToast(null),2600);
  }

  function reserve(mid,hour,type){
    const key=type==="washer"?"washer":"dryer";
    if(wkCount[key]>=3){showToast("이번 주 예약 횟수(3회) 초과","err");return;}
    if(ms[mid].reservations[hour]){showToast("이미 예약된 시간입니다.","err");return;}
    if(ms[mid].broken){showToast("고장 신고된 기계입니다.","err");return;}
    setMs(prev=>({...prev,[mid]:{...prev[mid],
      reservations:{...prev[mid].reservations,[hour]:{userId:user.id,room:user.room,name:user.name}}}}));
    setWkCount(p=>({...p,[key]:p[key]+1}));
    showToast(`${tLabel(hour)} ${type==="washer"?"세탁기":"건조기"} 예약 완료!`);
  }

  function cancel(mid,hour,type){
    const res=ms[mid].reservations[hour];
    if(!res||res.userId!==user.id)return;
    const updated={...ms[mid].reservations};
    delete updated[hour];
    setMs(prev=>({...prev,[mid]:{...prev[mid],reservations:updated}}));
    const key=type==="washer"?"washer":"dryer";
    setWkCount(p=>({...p,[key]:Math.max(0,p[key]-1)}));
    showToast("예약이 취소되었습니다.","info");
  }

  function startDryer(mid){
    setMs(prev=>({...prev,[mid]:{...prev[mid],running:true,runningUntil:Date.now()+50*60*1000}}));
    showToast("건조 시작! 50분 후 자동 해제됩니다.");
  }

  function sendMsg(){
    if(!msgText.trim())return;
    const msg={to:msgTarget.ownerRoom,from:user.room,fromName:user.name,
      text:msgText,machine:msgTarget.mid,
      time:new Date().toLocaleTimeString("ko-KR",{hour:"2-digit",minute:"2-digit"})};
    setInbox(p=>[...p,msg]);
    setMsgTarget(null);setMsgText("");
    showToast(`${msgTarget.ownerRoom}에 쪽지를 전송했습니다.`);
  }

  function report(mid){
    if(rpCount>=3){showToast("이번 주 신고 횟수(3회) 초과","err");return;}
    if(!rpReason.trim()){showToast("사유를 입력해주세요.","err");return;}
    // 횟수 복구
    const type=mid.startsWith("W")?"washer":"dryer";
    const myResCount=Object.values(ms[mid].reservations).filter(r=>r.userId===user.id).length;
    setMs(prev=>({...prev,[mid]:{...prev[mid],broken:true}}));
    setRpCount(p=>p+1);
    setWkCount(p=>({...p,[type]:Math.max(0,p[type]-myResCount)}));
    setRpTarget(null);setRpReason("");
    showToast("고장 신고 완료. 예약 횟수가 복구되었습니다.","info");
  }

  const myInboxMsgs=inbox.filter(m=>m.to===user?.room);

  if(!user)return <Login onLogin={setUser}/>;

  const list=tab==="washer"?MACHINES.washers:MACHINES.dryers;

  return (
    <div style={{minHeight:"100vh",background:C.bg}}>
      {/* 상단 바 */}
      <div style={{background:C.accent,color:"#fff",padding:"13px 20px",
        display:"flex",alignItems:"center",justifyContent:"space-between",
        position:"sticky",top:0,zIndex:200,boxShadow:"0 3px 14px rgba(59,91,219,.3)"}}>
        <div style={{display:"flex",alignItems:"center",gap:10}}>
          <span style={{fontSize:22}}>🧺</span>
          <div>
            <div style={{fontWeight:800,fontSize:15}}>기숙사 세탁실 예약</div>
            <div style={{fontSize:11,opacity:.8}}>{user.name} · {user.room}</div>
          </div>
        </div>
        <div style={{display:"flex",gap:8}}>
          <button onClick={()=>setShowInbox(v=>!v)}
            style={{...btn("#fff","rgba(255,255,255,.18)"),border:"1.5px solid rgba(255,255,255,.4)",
              position:"relative"}}>
            📬 쪽지함
            {myInboxMsgs.length>0&&(
              <span style={{position:"absolute",top:-7,right:-7,background:C.red,color:"#fff",
                borderRadius:"50%",width:18,height:18,fontSize:11,fontWeight:800,
                display:"flex",alignItems:"center",justifyContent:"center"}}>
                {myInboxMsgs.length}
              </span>
            )}
          </button>
          <button onClick={()=>setUser(null)}
            style={{...btn("#fff","rgba(255,255,255,.13)"),border:"1.5px solid rgba(255,255,255,.35)"}}>
            로그아웃
          </button>
        </div>
      </div>

      <div style={{maxWidth:980,margin:"0 auto",padding:"20px 14px"}}>
        {/* 주간 현황 카드 */}
        <div style={{display:"grid",gridTemplateColumns:"repeat(3,1fr)",gap:12,marginBottom:20}}>
          {[
            {icon:"🌀",label:"세탁기 이용",val:`${wkCount.washer} / 3회`,co:C.accent},
            {icon:"♨️",label:"건조기 이용",val:`${wkCount.dryer} / 3회`,co:C.green},
            {icon:"🔧",label:"고장 신고",val:`${rpCount} / 3회`,co:C.yellow},
          ].map(x=>(
            <div key={x.label} style={{background:C.surface,borderRadius:12,padding:"14px 16px",
              border:`1px solid ${C.border}`,boxShadow:"0 2px 8px rgba(0,0,0,.04)"}}>
              <div style={{fontSize:20,marginBottom:4}}>{x.icon}</div>
              <div style={{fontSize:18,fontWeight:800,color:x.co}}>{x.val}</div>
              <div style={{fontSize:11,color:C.gray}}>{x.label} (이번 주)</div>
            </div>
          ))}
        </div>

        {/* 탭 */}
        <div style={{display:"flex",gap:8,marginBottom:18}}>
          {[{k:"washer",l:"🌀 세탁기"},{k:"dryer",l:"♨️ 건조기"}].map(t=>(
            <button key={t.k} onClick={()=>setTab(t.k)}
              style={{padding:"9px 22px",borderRadius:10,border:"none",fontSize:14,fontWeight:700,
                background:tab===t.k?C.accent:C.surface,
                color:tab===t.k?"#fff":C.sub,
                boxShadow:tab===t.k?"0 4px 12px rgba(59,91,219,.3)":"none",
                transition:"all .15s"}}>
              {t.l}
            </button>
          ))}
        </div>

        {/* 기계 그리드 */}
        <div style={{display:"grid",gridTemplateColumns:"repeat(auto-fill,minmax(330px,1fr))",gap:14}}>
          {list.map(m=>(
            <MachineCard key={m.id} machine={m} state={ms[m.id]}
              isDryer={tab==="dryer"} user={user}
              onReserve={h=>reserve(m.id,h,tab)}
              onCancel={h=>cancel(m.id,h,tab)}
              onMsg={(h,room)=>setMsgTarget({mid:m.id,h,ownerRoom:room})}
              onReport={()=>setRpTarget(m.id)}
              onStartDryer={()=>startDryer(m.id)}
            />
          ))}
        </div>
      </div>

      {/* 쪽지함 모달 */}
      {showInbox&&(
        <Modal title={`📬 받은 쪽지 (${myInboxMsgs.length})`} onClose={()=>setShowInbox(false)}>
          {myInboxMsgs.length===0
            ?<div style={{color:C.gray,textAlign:"center",padding:"20px 0",fontSize:14}}>받은 쪽지가 없습니다.</div>
            :myInboxMsgs.map((m,i)=>(
              <div key={i} style={{background:C.card,borderRadius:10,padding:"12px 14px",
                marginBottom:10,border:`1px solid ${C.border}`}}>
                <div style={{display:"flex",justifyContent:"space-between",marginBottom:5}}>
                  <span style={{fontWeight:700,fontSize:13,color:C.accent}}>{m.fromName} ({m.from})</span>
                  <span style={{fontSize:11,color:C.gray}}>{m.time}</span>
                </div>
                <div style={{fontSize:13,color:C.text}}>{m.text}</div>
                <div style={{fontSize:11,color:C.gray,marginTop:4}}>기계: {m.machine}</div>
              </div>
            ))
          }
        </Modal>
      )}

      {/* 쪽지 전송 모달 */}
      {msgTarget&&(
        <Modal title="💬 이용자에게 쪽지 전송" onClose={()=>{setMsgTarget(null);setMsgText("");}}>
          <div style={{fontSize:13,color:C.sub,marginBottom:10}}>
            수신자: <strong>{msgTarget.ownerRoom}</strong> ({msgTarget.mid})
          </div>
          <textarea value={msgText} onChange={e=>setMsgText(e.target.value)}
            placeholder="메시지를 입력하세요..."
            style={{border:`1.5px solid ${C.border}`,borderRadius:8,padding:"9px 12px",
              fontSize:14,width:"100%",height:90,resize:"vertical",outline:"none",
              background:C.card,color:C.text}}/>
          <button onClick={sendMsg}
            style={{width:"100%",marginTop:12,background:C.accent,color:"#fff",
              border:"none",borderRadius:8,padding:"11px 0",fontSize:14,fontWeight:700}}>
            전송
          </button>
        </Modal>
      )}

      {/* 고장 신고 모달 */}
      {rpTarget&&(
        <Modal title="🔧 고장 신고" onClose={()=>{setRpTarget(null);setRpReason("");}}>
          <div style={{fontSize:13,color:C.sub,marginBottom:10}}>
            기계: <strong>{rpTarget}</strong>
          </div>
          <textarea value={rpReason} onChange={e=>setRpReason(e.target.value)}
            placeholder="고장 사유를 입력하세요..."
            style={{border:`1.5px solid ${C.border}`,borderRadius:8,padding:"9px 12px",
              fontSize:14,width:"100%",height:80,resize:"vertical",outline:"none",
              background:C.card,color:C.text}}/>
          <button onClick={()=>report(rpTarget)}
            style={{width:"100%",marginTop:12,background:C.red,color:"#fff",
              border:"none",borderRadius:8,padding:"11px 0",fontSize:14,fontWeight:700}}>
            신고 제출
          </button>
        </Modal>
      )}

      {/* 토스트 */}
      {toast&&(
        <div style={{position:"fixed",bottom:28,left:"50%",transform:"translateX(-50%)",
          background:toast.type==="err"?C.red:toast.type==="info"?C.yellow:C.green,
          color:"#fff",padding:"11px 26px",borderRadius:40,fontWeight:700,fontSize:14,
          boxShadow:"0 8px 24px rgba(0,0,0,.22)",zIndex:9999,
          animation:"fadeUp .2s ease",whiteSpace:"nowrap"}}>
          {toast.msg}
        </div>
      )}
    </div>
  );
}

ReactDOM.createRoot(document.getElementById("root")).render(<App/>);
</script>
</body>
</html>

