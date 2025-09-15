<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>Simple eCommerce Demo</title>
  <meta name="description" content="A single-file demo eCommerce site (HTML/CSS/JS) with products, cart, and mock checkout." />
  <style>
    /* Simple reset */
    * { box-sizing: border-box; }
    html,body{ height:100%; margin:0; font-family: Inter, system-ui, -apple-system, 'Segoe UI', Roboto, 'Helvetica Neue', Arial; color:#111 }

    header{ background: linear-gradient(90deg,#4b6cb7,#182848); color:white; padding:1rem; display:flex; gap:1rem; align-items:center; justify-content:space-between}
    .brand{ display:flex; gap:.75rem; align-items:center }
    .brand h1{ margin:0; font-size:1.15rem }

    .container{ max-width:1100px; margin:1.25rem auto; padding:0 1rem }

    /* Layout */
    .grid{ display:grid; grid-template-columns: repeat(auto-fit,minmax(240px,1fr)); gap:1rem }
    .card{ border:1px solid #e6e9ef; border-radius:10px; overflow:hidden; background:white; display:flex; flex-direction:column; height:100% }
    .card img{ width:100%; height:180px; object-fit:cover }
    .card .body{ padding:0.75rem; display:flex; flex-direction:column; gap:.5rem; flex:1 }
    .price{ font-weight:700 }
    .actions{ margin-top:auto; display:flex; gap:.5rem }
    button{ cursor:pointer; border:0; padding:.5rem .6rem; border-radius:8px }
    .btn-primary{ background:#2563eb; color:white }
    .btn-ghost{ background:transparent; color:#334155; border:1px solid #e6e9ef }

    /* Cart drawer */
    .cart-button{ position:relative }
    .cart-count{ position:absolute; top:-8px; right:-8px; background:#ef4444; color:white; font-size:0.75rem; padding:3px 6px; border-radius:999px }

    .drawer{ position:fixed; right:0; top:0; bottom:0; width:360px; max-width:95%; background:#f8fafc; border-left:1px solid #e6e9ef; transform:translateX(100%); transition:transform .22s ease; z-index:60; display:flex; flex-direction:column }
    .drawer.open{ transform:translateX(0) }
    .drawer header{ padding:1rem; background:white; display:flex; justify-content:space-between; align-items:center; border-bottom:1px solid #e6e9ef }
    .drawer .content{ padding:1rem; overflow:auto; flex:1 }
    .drawer .footer{ padding:1rem; border-top:1px solid #e6e9ef; background:white }
    .line{ display:flex; justify-content:space-between; gap:1rem }
    .muted{ color:#6b7280 }

    /* Checkout modal */
    .modal-backdrop{ position:fixed; inset:0; background:rgba(2,6,23,0.5); display:flex; justify-content:center; align-items:center; z-index:80 }
    .modal{ width:520px; max-width:95%; background:white; border-radius:12px; overflow:hidden }
    .modal .body{ padding:1rem }
    label{ display:block; font-size:0.85rem; margin-bottom:6px }
    input,select,textarea{ width:100%; padding:.6rem; border-radius:8px; border:1px solid #e6e9ef; margin-bottom:0.75rem }

    footer{ text-align:center; padding:1rem; color:#6b7280 }

    /* Responsive tweaks */
    @media (max-width:600px){ .card img{ height:140px } .drawer{ width:100% } }

    /* small helper */
    .empty{ text-align:center; padding:2rem; color:#64748b }
  </style>
</head>
<body>
  <header>
    <div class="brand">
      <svg width="36" height="36" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><rect width="24" height="24" rx="5" fill="#fff"/><path d="M4 12h16M12 4v16" stroke="#fff" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round"/></svg>
      <div>
        <h1>CK Shop — Demo</h1>
        <div style="font-size:0.78rem; color:rgba(255,255,255,0.85)">Single-file HTML eCommerce</div>
      </div>
    </div>
    <div style="display:flex; gap:.5rem; align-items:center">
      <div class="cart-button">
        <button id="openCartBtn" class="btn-ghost">Cart</button>
        <div id="cartCount" class="cart-count" style="display:none">0</div>
      </div>
      <button id="clearBtn" class="btn-ghost">Clear Data</button>
    </div>
  </header>

  <main class="container">
    <section style="display:flex; justify-content:space-between; align-items:center; margin-bottom:1rem">
      <h2 style="margin:0">Products</h2>
      <div class="muted">Demo store — no payments, local-only</div>
    </section>

    <section id="products" class="grid"></section>

    <section style="margin-top:1.5rem">
      <h3>How it works</h3>
      <p class="muted">This demo shows product listing, add to cart, quantity editing, and a mock checkout form. Cart is saved to <code>localStorage</code>. Replace product images and expand for real projects.</p>
    </section>
  </main>

  <div class="drawer" id="cartDrawer" aria-hidden="true">
    <header>
      <strong>Shopping Cart</strong>
      <div>
        <button id="closeCartBtn" class="btn-ghost">Close</button>
      </div>
    </header>
    <div class="content" id="cartContent">
      <!-- items injected here -->
    </div>
    <div class="footer">
      <div class="line" style="margin-bottom:.5rem"><div class="muted">Subtotal</div><div id="subtotal">₹0.00</div></div>
      <div style="display:flex; gap:.5rem">
        <button id="checkoutBtn" class="btn-primary" style="flex:1">Checkout</button>
        <button id="emptyCartBtn" class="btn-ghost">Empty</button>
      </div>
    </div>
  </div>

  <!-- Checkout Modal -->
  <div id="modalBackdrop" style="display:none" class="modal-backdrop">
    <div class="modal">
      <header style="padding:1rem; border-bottom:1px solid #e6e9ef; display:flex; justify-content:space-between; align-items:center">
        <strong>Checkout</strong>
        <button id="closeModal" class="btn-ghost">X</button>
      </header>
      <div class="body">
        <form id="checkoutForm">
          <div style="display:grid; grid-template-columns:1fr 1fr; gap:0.5rem">
            <div>
              <label for="fname">First name</label>
              <input id="fname" required />
            </div>
            <div>
              <label for="lname">Last name</label>
              <input id="lname" required />
            </div>
          </div>

          <label for="email">Email</label>
          <input id="email" type="email" required />

          <label for="address">Address</label>
          <textarea id="address" rows="3" required></textarea>

          <label for="shipping">Shipping method</label>
          <select id="shipping">
            <option value="standard">Standard — Free</option>
            <option value="express">Express — ₹199</option>
          </select>

          <div style="display:flex; gap:.5rem; margin-top:.5rem">
            <button type="submit" class="btn-primary" style="flex:1">Place order (mock)</button>
            <button type="button" id="cancelCheckout" class="btn-ghost">Cancel</button>
          </div>
        </form>
      </div>
    </div>
  </div>

  <footer>
    © CK Shop Demo — client-only. Built with plain HTML/CSS/JS. Use for learning & prototypes.
  </footer>

  <script>
  // ---------- Demo product data ----------
  const PRODUCTS = [
    { id: 'p1', title: 'Classic Camera', price: 4999, img: 'https://images.unsplash.com/photo-1519183071298-a2962be54f16?q=80&w=800&auto=format&fit=crop&ixlib=rb-4.0.3&s=1' },
    { id: 'p2', title: 'Stylish Headphones', price: 2999, img: 'https://images.unsplash.com/photo-1518444028036-6b7e4b4b1621?q=80&w=800&auto=format&fit=crop&ixlib=rb-4.0.3&s=2' },
    { id: 'p3', title: 'Leather Bag', price: 3499, img: 'https://images.unsplash.com/photo-1520975913008-6b6c7c0d3b2a?q=80&w=800&auto=format&fit=crop&ixlib=rb-4.0.3&s=3' },
    { id: 'p4', title: 'Sunglasses', price: 899, img: 'https://images.unsplash.com/photo-1503342217505-b0a15b9c7e36?q=80&w=800&auto=format&fit=crop&ixlib=rb-4.0.3&s=4' },
    { id: 'p5', title: 'Sneakers', price: 2599, img: 'https://images.unsplash.com/photo-1519741491074-3df7d7a0d4a6?q=80&w=800&auto=format&fit=crop&ixlib=rb-4.0.3&s=5' }
  ];

  // ---------- Simple cart implementation ----------
  let cart = loadCart();

  const productsEl = document.getElementById('products');
  const cartCountEl = document.getElementById('cartCount');
  const cartDrawer = document.getElementById('cartDrawer');
  const cartContent = document.getElementById('cartContent');
  const subtotalEl = document.getElementById('subtotal');

  function renderProducts(){
    productsEl.innerHTML = '';
    PRODUCTS.forEach(p => {
      const card = document.createElement('article');
      card.className = 'card';
      card.innerHTML = `
        <img src="${p.img}" alt="${p.title}" />
        <div class="body">
          <div style="display:flex; justify-content:space-between; align-items:center">
            <div>
              <h3 style="margin:0; font-size:1rem">${p.title}</h3>
              <div class="muted" style="font-size:0.82rem">SKU: ${p.id}</div>
            </div>
            <div class="price">₹${formatCurrency(p.price)}</div>
          </div>
          <p class="muted" style="font-size:0.9rem; margin:0.6rem 0 .2rem">Great product description goes here. Replace with real content.</p>
          <div class="actions">
            <button class="btn-primary" data-add="${p.id}">Add to cart</button>
            <button class="btn-ghost" data-view="${p.id}">View</button>
          </div>
        </div>
      `;
      productsEl.appendChild(card);
    });
  }

  // helper
  function formatCurrency(n) { return Number(n).toLocaleString('en-IN') }

  // ---------- Cart functions ----------
  function loadCart(){
    try{ const raw = localStorage.getItem('ck_cart'); return raw ? JSON.parse(raw) : {} } catch(e){ return {} }
  }
  function saveCart(){ localStorage.setItem('ck_cart', JSON.stringify(cart)); updateCartUI(); }

  function addToCart(productId, qty = 1){
    cart[productId] = (cart[productId] || 0) + qty;
    saveCart();
    flashCartCount();
  }

  function removeFromCart(productId){ delete cart[productId]; saveCart(); }
  function setQty(productId, qty){ if(qty<=0) removeFromCart(productId); else { cart[productId] = qty; saveCart(); } }
  function emptyCart(){ cart = {}; saveCart(); }

  function cartItems(){
    return Object.entries(cart).map(([id,qty]) => {
      const p = PRODUCTS.find(x=>x.id===id);
      return p ? { ...p, qty } : null;
    }).filter(Boolean);
  }

  function cartTotal(){
    return cartItems().reduce((s,i)=> s + (i.price * i.qty), 0);
  }

  // ---------- Cart UI ----------
  function updateCartUI(){
    const items = cartItems();
    const count = items.reduce((s,i)=> s + i.qty, 0);
    if(count>0){ cartCountEl.style.display='block'; cartCountEl.textContent = count } else cartCountEl.style.display='none';

    subtotalEl.textContent = `₹${formatCurrency(cartTotal())}`;

    // render drawer content
    cartContent.innerHTML = '';
    if(items.length===0){ cartContent.innerHTML = '<div class="empty">Your cart is empty.</div>'; return }

    items.forEach(i=>{
      const row = document.createElement('div');
      row.style.display='flex'; row.style.gap='0.6rem'; row.style.marginBottom='0.6rem'; row.style.alignItems='center'
      row.innerHTML = `
        <img src="${i.img}" style="width:64px;height:64px;object-fit:cover;border-radius:8px;" />
        <div style="flex:1">
          <div style="display:flex; justify-content:space-between; align-items:center">
            <strong style="font-size:0.95rem">${i.title}</strong>
            <div class="muted">₹${formatCurrency(i.price)}</div>
          </div>
          <div style="display:flex; gap:.4rem; align-items:center; margin-top:.4rem">
            <button class="btn-ghost" data-decrease="${i.id}">-</button>
            <input type="number" value="${i.qty}" min="1" style="width:64px;padding:.35rem;border-radius:8px;border:1px solid #e6e9ef" data-qinput="${i.id}" />
            <button class="btn-ghost" data-increase="${i.id}">+</button>
            <button class="btn-ghost" data-remove="${i.id}">Remove</button>
          </div>
        </div>
      `;
      cartContent.appendChild(row);
    });
  }

  // ---------- Event listeners ----------
  document.body.addEventListener('click', e => {
    const add = e.target.closest('[data-add]');
    if(add){ addToCart(add.dataset.add); return }

    const view = e.target.closest('[data-view]');
    if(view){ alert('Product: ' + view.dataset.view); return }

    const openCart = e.target.closest('#openCartBtn');
    if(openCart){ cartDrawer.classList.add('open'); cartDrawer.setAttribute('aria-hidden','false'); return }

    const closeCart = e.target.closest('#closeCartBtn');
    if(closeCart){ cartDrawer.classList.remove('open'); cartDrawer.setAttribute('aria-hidden','true'); return }

    const emptyBtn = e.target.closest('#emptyCartBtn');
    if(emptyBtn){ if(confirm('Empty cart?')) emptyCart(); return }

    const clearData = e.target.closest('#clearBtn');
    if(clearData){ if(confirm('Clear localStorage (cart + settings)?')){ localStorage.clear(); cart = {}; updateCartUI(); alert('Cleared local storage'); } return }

    const checkout = e.target.closest('#checkoutBtn');
    if(checkout){ openModal(); return }
  });

  // drawer quantity buttons and inputs (delegated)
  cartContent.addEventListener('click', e => {
    const dec = e.target.closest('[data-decrease]');
    if(dec){ const id = dec.dataset.decrease; setQty(id, (cart[id]||0)-1); return }
    const inc = e.target.closest('[data-increase]');
    if(inc){ const id = inc.dataset.increase; setQty(id, (cart[id]||0)+1); return }
    const rem = e.target.closest('[data-remove]');
    if(rem){ const id = rem.dataset.remove; removeFromCart(id); return }
  });

  cartContent.addEventListener('change', e=>{
    const input = e.target.closest('[data-qinput]');
    if(input){ const id = input.dataset.qinput; const v = parseInt(input.value||'0',10); setQty(id, v); }
  });

  // checkout modal
  const modalBackdrop = document.getElementById('modalBackdrop');
  const closeModalBtn = document.getElementById('closeModal');
  const cancelCheckout = document.getElementById('cancelCheckout');
  const checkoutForm = document.getElementById('checkoutForm');

  function openModal(){
    if(cartItems().length===0){ alert('Cart is empty'); return }
    modalBackdrop.style.display='flex';
  }
  function closeModal(){ modalBackdrop.style.display='none'; }

  closeModalBtn.addEventListener('click', closeModal);
  cancelCheckout.addEventListener('click', closeModal);
  modalBackdrop.addEventListener('click', e => { if(e.target === modalBackdrop) closeModal(); });

  checkoutForm.addEventListener('submit', e => {
    e.preventDefault();
    // gather order details
    const order = {
      name: document.getElementById('fname').value + ' ' + document.getElementById('lname').value,
      email: document.getElementById('email').value,
      address: document.getElementById('address').value,
      shipping: document.getElementById('shipping').value,
      items: cartItems(),
      subtotal: cartTotal(),
      placedAt: new Date().toISOString()
    };

    // In a real app you'd send `order` to your backend. Here we just show a confirmation and clear cart.
    console.log('Mock order created', order);
    alert('Order placed (mock). Check console for order object.');
    emptyCart();
    closeModal();
  });

  // small visual feedback for cart change
  function flashCartCount(){
    cartCountEl.animate([{ transform: 'scale(1)' }, { transform: 'scale(1.2)' }, { transform: 'scale(1)' }], { duration: 260 });
  }

  // clear storage button
  document.getElementById('closeCartBtn').addEventListener('keydown', e=>{ if(e.key==='Enter') cartDrawer.classList.remove('open'); });

  // initialization
  renderProducts();
  updateCartUI();

  // make sure drawer updates when storage changes in other tabs
  window.addEventListener('storage', e => { if(e.key==='ck_cart') { cart = loadCart(); updateCartUI(); } });

  </script>
</body>
</html>
