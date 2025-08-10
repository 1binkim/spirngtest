<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>장바구니</title>
<style>
  body { font-family: 'Noto Sans KR', sans-serif; margin:0; background:#f9f9f9; }
  .wrap { max-width: 1000px; margin: 40px auto; background: #fff; padding: 24px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,.06); }
  table { width:100%; border-collapse: collapse; }
  th, td { padding:12px; border-bottom:1px solid #eee; text-align: left; vertical-align: middle; }
  .thumb { width:64px; height:86px; background:#ddd; background-size:cover; background-position:center; border-radius:6px; }
  .qty { width:64px; }
  .right { text-align:right; }
  .total { font-weight:700; font-size:18px; }
  .empty { padding:40px 0; text-align:center; color:#666; }
  .actions { margin-top:16px; display:flex; justify-content:flex-end; }
  .btn-primary { padding:10px 14px; border-radius:8px; background:#007bff; color:#fff; border:0; cursor:pointer; }
  .btn-primary[disabled] { opacity:.5; cursor:not-allowed; }
</style>

<c:if test="${not empty _csrf}">
  <meta name="_csrf_header" content="${_csrf.headerName}" />
  <meta name="_csrf" content="${_csrf.token}" />
</c:if>
</head>
<body>
<div class="wrap">
  <h2>장바구니</h2>

  <div id="empty" class="empty" style="display:none;">장바구니가 비어 있습니다.</div>

  <table id="cartTable" style="display:none;">
    <thead>
      <tr><th>도서</th><th>가격</th><th>수량</th><th class="right">소계</th><th></th></tr>
    </thead>
    <tbody id="cartBody"></tbody>
    <tfoot>
      <tr>
        <td colspan="3" class="right total">총 합계</td>
        <td class="right total" id="grandTotal">0</td>
        <td></td>
      </tr>
    </tfoot>
  </table>

  <!-- 결제 영역: 표 바로 아래, 오른쪽 정렬 -->
  <div class="actions">
    <form id="checkoutForm" method="post" action="${pageContext.request.contextPath}/bookstore/checkout">
      <c:if test="${not empty _csrf}">
        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
      </c:if>
      <button id="checkoutBtn" type="submit" class="btn-primary" disabled>결제하기</button>
    </form>
  </div>
</div>

<!-- 서버 URL은 JSTL로만 생성 -->
<c:url var="resolveUrl" value="/bookstore/cart/resolve"/>

<script>
// ===== 쿠키: Base64 + Path=/bookstore (읽기만 필요) =====
function readCartCookie(){
  const all = document.cookie.split(';').map(s=>s.trim()).filter(s=>s.startsWith('cart='));
  if(all.length === 0) return { i: [] };
  const raw = all[all.length - 1].slice('cart='.length);
  try { return JSON.parse(decodeURIComponent(atob(raw))); }
  catch(e){ try { return JSON.parse(decodeURIComponent(raw)); } catch(e2){ return { i: [] }; } }
}
function formatWon(n){ return (Number(n)||0).toLocaleString('ko-KR'); }
function csrfHeaders(){
  const h = document.querySelector('meta[name="_csrf_header"]')?.content;
  const t = document.querySelector('meta[name="_csrf"]')?.content;
  return (h && t) ? { [h]: t } : {};
}

// 서버 해석
async function resolveCart(){
  const payload = readCartCookie();  // { i:[{id,q}] }
  const res = await fetch("${resolveUrl}", {
    method: 'POST',
    headers: Object.assign({ 'Content-Type': 'application/json' }, csrfHeaders()),
    body: JSON.stringify(payload),
    credentials: 'same-origin'
  });
  if (res.redirected) { window.location.href = res.url; return []; }
  const ct = res.headers.get('content-type') || '';
  if (!ct.includes('application/json')) throw new Error('unexpected content-type');
  
  if (!res.ok) {
    const err = await res.text().catch(()=> '');
    throw new Error('resolve 실패: ' + res.status + ' ' + err);
  }
  return res.json(); // [{id,title,price,stock,coverImage,qty}]
}

// DOM
const table = document.getElementById('cartTable');
const empty = document.getElementById('empty');
const body  = document.getElementById('cartBody');
const grand = document.getElementById('grandTotal');
const checkoutBtn = document.getElementById('checkoutBtn');

function safeCover(url){
  if (!url || typeof url !== 'string') return '';
  const u = url.trim();
  const lower = u.toLowerCase();
  if (lower.startsWith('javascript:')) return '';
  if (lower.startsWith('data:') && !lower.startsWith('data:image/')) return '';
  return u.replace(/'/g, "\\'").replace(/[\n\r]/g, '');
}

function updateCheckoutState(hasItems){
  // 아이템이 하나라도 있으면 결제 가능, 없으면 비활성
  checkoutBtn.disabled = !hasItems;
}

function render(items){
  const hasItems = Array.isArray(items) && items.length > 0;

  if (!hasItems){
    table.style.display='none';
    empty.style.display='block';
    body.innerHTML = '';
    grand.textContent = '0';
    updateCheckoutState(false);
    return;
  }

  table.style.display='table';
  empty.style.display='none';
  body.innerHTML = '';
  let total = 0;

  for (const it of items){
    const price = Number(it.price)||0;
    const qty   = Math.max(1, Number(it.qty)||1);
    const sub   = price * qty;
    total += sub;

    const tr = document.createElement('tr');
    tr.innerHTML =
      '<td>' +
        '<div style="display:flex; gap:12px; align-items:center;">' +
          '<div class="thumb" style="background-image:url(\'' + safeCover(it.coverImage) + '\')"></div>' +
          '<div>' +
            '<div style="font-weight:600">' + (it.title ? String(it.title) : '') + '</div>' +
            '<div style="color:#888; font-size:12px">재고: ' + (Number(it.stock)||0) + '</div>' +
          '</div>' +
        '</div>' +
      '</td>' +
      '<td>' + formatWon(price) + '원</td>' +
      '<td>' +
        '<input class="qty" type="number" min="1" max="' + (Number(it.stock)||1) + '" value="' + qty + '" data-id="' + Number(it.id) + '">' +
      '</td>' +
      '<td class="right"><span class="sub">' + formatWon(sub) + '</span>원</td>' +
      '<td><button class="btn-del" data-del="' + Number(it.id) + '">삭제</button></td>';

    body.appendChild(tr);
  }
  grand.textContent = formatWon(total);
  updateCheckoutState(true);
}

// 수량 변경/삭제 시 서버 재해석 → 버튼 상태도 자동 반영
body.addEventListener('change', (e)=>{
  if (!e.target.classList.contains('qty')) return;
  const id  = Number(e.target.dataset.id);
  let qty   = Number(e.target.value || 1);
  const max = Number(e.target.getAttribute('max') || 99);
  if (qty < 1) qty = 1;
  if (qty > max) qty = max;
  e.target.value = qty;

  // 쿠키 업데이트 (Base64 포맷 + Path=/bookstore) — 장바구니 페이지에서는 읽기만, 업데이트는 서버쪽 설계에 맞게
  const c = readCartCookie();
  const list = (c.i || []).map(x => x.id === id ? ({ id, q: qty }) : x);
  // 간단히 클라이언트에서 재저장
  const encoded = btoa(encodeURIComponent(JSON.stringify({ i: list })));
  document.cookie = 'cart=' + encoded + '; Path=/bookstore; Max-Age=' + (60*60*24*14) + '; SameSite=Lax';

  boot();
});
body.addEventListener('click', (e)=>{
  const id = e.target.getAttribute('data-del');
  if (!id) return;
  const c = readCartCookie();
  const list = (c.i || []).filter(x => x.id !== Number(id));
  const encoded = btoa(encodeURIComponent(JSON.stringify({ i: list })));
  document.cookie = 'cart=' + encoded + '; Path=/bookstore; Max-Age=' + (60*60*24*14) + '; SameSite=Lax';
  boot();
},{capture:true});

// 시작
async function boot(){
  try{
    // 과거 Path=/ 쿠키가 남아있을 수 있으니 제거
    document.cookie = 'cart=; Path=/; Max-Age=0; SameSite=Lax';
    const items = await resolveCart();
    render(items);
  }catch(e){
    console.error(e);
    empty.textContent = '장바구니 로딩 오류';
    empty.style.display = 'block';
    document.getElementById('cartTable').style.display = 'none';
    updateCheckoutState(false);
  }
}
boot();
</script>
</body>
</html>
