const toggle = document.querySelector('.menu-toggle');
const navLinks = document.querySelector('.nav-links');

toggle?.addEventListener('click', () => {
  const isOpen = navLinks.classList.toggle('open');
  toggle.setAttribute('aria-expanded', String(isOpen));
});

navLinks?.querySelectorAll('a').forEach((link) => link.addEventListener('click', () => {
  navLinks.classList.remove('open');
  toggle?.setAttribute('aria-expanded', 'false');
}));

const observer = new IntersectionObserver((entries) => {
  entries.forEach((entry) => {
    if (entry.isIntersecting) {
      entry.target.classList.add('visible');
      observer.unobserve(entry.target);
    }
  });
}, { threshold: 0.16 });
document.querySelectorAll('.reveal').forEach((element) => observer.observe(element));

function animateCounter(element) {
  const target = Number(element.dataset.value);
  const start = performance.now();
  const duration = 1500;
  const tick = (now) => {
    const progress = Math.min((now - start) / duration, 1);
    const eased = 1 - Math.pow(1 - progress, 3);
    element.textContent = `$${Math.round(target * eased).toLocaleString('en-US')}`;
    if (progress < 1) requestAnimationFrame(tick);
  };
  requestAnimationFrame(tick);
}
document.querySelectorAll('.counter').forEach(animateCounter);

document.querySelector('[data-coming-soon]')?.addEventListener('click', () => {
  document.querySelector('.coming-message').textContent = '下載連結準備中，敬請期待。';
});

function validateContactForm(form) {
  const values = Object.fromEntries(new FormData(form).entries());
  const errors = {};
  if (!String(values.name || '').trim()) errors.name = '請填寫姓名。';
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(String(values.email || '').trim())) errors.email = '請輸入有效的 Email。';
  if (!String(values.subject || '').trim()) errors.subject = '請填寫主旨。';
  if (String(values.message || '').trim().length < 10) errors.message = '訊息內容至少需要 10 個字元。';
  form.querySelectorAll('[data-error-for]').forEach((message) => {
    const field = message.dataset.errorFor;
    const input = form.elements[field];
    message.textContent = errors[field] || '';
    input.classList.toggle('invalid', Boolean(errors[field]));
    input.setAttribute('aria-invalid', String(Boolean(errors[field])));
  });
  return { values, errors };
}

async function saveContactMessage({ name, email, subject, message }) {
  if (!supabase) throw new Error('尚未設定 Supabase URL 與 anon key。');
  const { error } = await supabase.from('contact_messages').insert({
    name: name.trim(), email: email.trim(), subject: subject.trim(), message: message.trim(),
  });
  if (error) throw error;
}

const contactForm = document.querySelector('#contact-form');
contactForm?.addEventListener('submit', async (event) => {
  event.preventDefault();
  const status = document.querySelector('#form-status');
  const submit = contactForm.querySelector('.form-submit');
  const { values, errors } = validateContactForm(contactForm);
  status.textContent = '';
  status.className = 'form-status';
  if (Object.keys(errors).length) {
    status.textContent = '請先檢查標示的欄位。';
    status.classList.add('error');
    return;
  }
  submit.disabled = true;
  submit.querySelector('span').textContent = '…';
  try {
    await saveContactMessage(values);
    contactForm.reset();
    status.textContent = '訊息已送出，謝謝你的來信！';
    status.classList.add('success');
  } catch (error) {
    console.error('Unable to save contact message:', error);
    status.textContent = error.message.includes('尚未設定')
      ? '表單尚未連接 Supabase，請先完成設定。'
      : '送出失敗，請稍後再試。';
    status.classList.add('error');
  } finally {
    submit.disabled = false;
    submit.querySelector('span').textContent = '→';
  }
});
import { createClient } from 'https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/+esm';

// Replace these two placeholders with your Supabase project values.
const SUPABASE_URL = 'https://tydyqodxpylvipwjfvcj.supabase.co';
const SUPABASE_ANON_KEY = 'sb_publishable_IzQdPEgdC9mhwTs2KaNiuw_TILc31yG';
const supabase = SUPABASE_URL.includes('YOUR_PROJECT') || SUPABASE_ANON_KEY.includes('YOUR_')
  ? null
  : createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
