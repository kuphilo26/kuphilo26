<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>고려대 기숙사 세탁실 예약 시스템</title>
<style>
*{
  box-sizing:border-box;
}
body{
  margin:0;
  font-family:Arial,sans-serif;
  background:#F0F4FF;
}
button{
  cursor:pointer;
}
#app{
  min-height:100vh;
}

/* 공통 */
.card{
  background:white;
  border-radius:14px;
  box-shadow:0 2px 12px rgba(0,0,0,.08);
  padding:20px;
}

.modal-bg{
  position:fixed;
  inset:0;
  background:rgba(0,0,0,.4);
  display:flex;
  align-items:center;
  justify-content:center;
  z-index:1000;
}

.modal{
  background:white;
  width:420px;
  border-radius:16px;
  padding:20px;
}

.toast{
  position:fixed;
  bottom:30px;
  left:50%;
  transform:translateX(-50%);
  background:#2F9E44;
  color:white;
  padding:12px 20px;
  border-radius:30px;
  font-weight:bold;
  z-index:9999;
}

.machine-grid{
  display:grid;
  grid-template-columns:repeat(auto-fill,minmax(340px,1fr));
  gap:16px;
}

.slot{
  width:52px;
  height:42px;
  border-radius:8px;
  border:1px solid #DDE3F0;
  display:flex;
  flex-direction:column;
  align-items:center;
  justify-content:center;
  font-size:10px;
  cursor:pointer;
}

.slot.free{
  background:#F0F4FF;
}
.slot.mine{
  background:#E8ECFF;
  border:1.5px solid #3B5BDB;
}
.slot.reserved{
  background:#FFF3BF;
}
.slot.past{
  background:#E9ECF0;
}
</style>
</head>
<body>
<div id="app"></div>

<script>const MACHINES = {
  washers: [
    {id:"W1", label:"세탁기 1호"},
    {id:"W2", label:"세탁기 2호"},
    {id:"W3", label:"세탁기 3호"},
    {id:"W4", label:"세탁기 4호"},
    {id:"W5", label:"세탁기 5호"},
    {id:"W6", label:"세탁기 6호"},
    {id:"W7", label:"세탁기 7호"},
    {id:"W8", label:"세탁기 8호"}
  ],
  dryers: [
    {id:"D1", label:"건조기 1호"},
    {id:"D2", label:"건조기 2호"},
    {id:"D3", label:"건조기 3호"},
    {id:"D4", label:"건조기 4호"},
    {id:"D5", label:"건조기 5호"},
    {id:"D6", label:"건조기 6호"},
    {id:"D7", label:"건조기 7호"},
    {id:"D8", label:"건조기 8호"}
  ]
};

const DEMO_USERS = [
  {
    id:"2026130124",
    password:"pass1",
    name:"신현",
    room:"302호"
  },
  {
    id:"2026000001",
    password:"pass2",
    name:"김철수",
    room:"115호"
  }
];

const HOURS = Array.from({length:16},(_,i)=>i+7);function pad(n){
  return String(n).padStart(2,"0");
}

function timeLabel(h){
  return `${pad(h)}:00`;
}

function nowHour(){
  return new Date().getHours();
}function initMachineState(){
  const state={};

  [...MACHINES.washers,...MACHINES.dryers].forEach(m=>{
    state[m.id]={
      reservations:{},
      running:false,
      runningUntil:null,
      broken:false
    };
  });

  state["W1"].reservations[9]={
    userId:"2026000001",
    room:"115호",
    name:"김철수"
  };

  return state;
}let appState = {
  user:null,
  tab:"washer",
  machines:initMachineState(),
  messages:[],
  toast:null,
  showInbox:false,
  myWeekCount:{
    washer:0,
    dryer:0
  },
  myReportCount:0,
  modal:null
};
