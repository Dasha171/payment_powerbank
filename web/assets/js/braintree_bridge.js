// braintree_bridge.js
// Полная реализация для работы с Braintree и Apple Pay

// Проверка поддержки Apple Pay
window.isApplePayAvailable = function() {
  try {
    if (window.ApplePaySession && ApplePaySession.canMakePayments()) {
      return true;
    }
  } catch (e) {
    console.log('Apple Pay not available:', e);
  }
  return false;
};

// Создание overlay для Drop-in
window._createDropinOverlay = function() {
  // Удаляем существующий overlay если есть
  const existing = document.getElementById('__dropin_overlay');
  if (existing) existing.remove();

  const overlay = document.createElement('div');
  overlay.id = '__dropin_overlay';
  overlay.style.position = 'fixed';
  overlay.style.left = '0';
  overlay.style.top = '0';
  overlay.style.width = '100%';
  overlay.style.height = '100%';
  overlay.style.background = 'rgba(0,0,0,0.5)';
  overlay.style.display = 'flex';
  overlay.style.alignItems = 'center';
  overlay.style.justifyContent = 'center';
  overlay.style.zIndex = '999999';

  const modal = document.createElement('div');
  modal.id = '__dropin_modal';
  modal.style.width = '400px';
  modal.style.maxWidth = '90%';
  modal.style.background = '#fff';
  modal.style.borderRadius = '16px';
  modal.style.padding = '24px';
  modal.style.boxSizing = 'border-box';
  modal.style.boxShadow = '0 10px 25px rgba(0,0,0,0.2)';

  const container = document.createElement('div');
  container.id = '__dropin_container';
  container.style.minHeight = '200px';

  modal.appendChild(container);

  // Закрытие при клике вне модала
  overlay.onclick = function(e) {
    if (e.target === overlay) {
      window.closeDropIn();
    }
  };

  overlay.appendChild(modal);
  document.body.appendChild(overlay);
  return { overlay, modal, container };
};

// Инициализация Drop-in
window.initDropIn = function(clientToken) {
  return new Promise(function(resolve, reject) {
    try {
      const elems = window._createDropinOverlay();
      
      // Создаем Drop-in
      braintree.dropin.create({
        authorization: clientToken,
        container: '#__dropin_container',
        card: {
          cardholderName: {
            required: true
          },
          styles: {
            input: {
              'font-size': '16px',
              'font-family': 'SF Pro Display, -apple-system, BlinkMacSystemFont, sans-serif'
            }
          }
        },
        paypal: {
          flow: 'vault'
        }
      }, function(createErr, instance) {
        if (createErr) {
          console.error('Drop-in creation error:', createErr);
          reject(createErr);
          return;
        }
        
        window._dropin = instance;

        // Добавляем кнопку оплаты
        const payBtn = document.createElement('button');
        payBtn.innerText = 'Pay $4.99';
        payBtn.style.display = 'block';
        payBtn.style.width = '100%';
        payBtn.style.marginTop = '20px';
        payBtn.style.padding = '16px';
        payBtn.style.borderRadius = '12px';
        payBtn.style.border = 'none';
        payBtn.style.background = '#000';
        payBtn.style.color = '#fff';
        payBtn.style.fontSize = '16px';
        payBtn.style.fontWeight = '600';
        payBtn.style.cursor = 'pointer';
        
        payBtn.onclick = function() {
          payBtn.disabled = true;
          payBtn.innerText = 'Processing...';
          
          instance.requestPaymentMethod().then(function(payload) {
            window._dropinPayload = payload;
            payBtn.innerText = 'Payment Successful!';
            payBtn.style.background = '#28a745';
          }).catch(function(err) {
            console.error('Payment method request error:', err);
            payBtn.disabled = false;
            payBtn.innerText = 'Pay $4.99';
            payBtn.style.background = '#000';
            alert('Payment failed: ' + err.message);
          });
        };
        
        elems.modal.appendChild(payBtn);
        resolve(true);
      });
    } catch (e) {
      reject(e);
    }
  });
};

// Запрос payment method
window.requestPaymentMethod = function() {
  return new Promise(function(resolve, reject) {
    try {
      if (window._dropinPayload && window._dropinPayload.nonce) {
        resolve(window._dropinPayload.nonce);
        return;
      }
      
      if (!window._dropin) {
        reject(new Error('Drop-in not initialized'));
        return;
      }
      
      window._dropin.requestPaymentMethod().then(function(payload) {
        resolve(payload.nonce);
      }).catch(function(err) {
        reject(err);
      });
    } catch (e) {
      reject(e);
    }
  });
};

// Закрытие Drop-in
window.closeDropIn = function() {
  try {
    const overlay = document.getElementById('__dropin_overlay');
    if (overlay) overlay.remove();
    
    if (window._dropin) {
      window._dropin.teardown(function(err) {
        if (err) console.log('Drop-in teardown error:', err);
      });
      window._dropin = null;
    }
    
    window._dropinPayload = null;
    return true;
  } catch (e) {
    console.error('Error closing Drop-in:', e);
    return false;
  }
};

// Apple Pay реализация с настоящим API
window.startApplePay = function(clientToken, amount) {
  return new Promise(function(resolve, reject) {
    try {
      // Проверяем доступность Apple Pay
      if (!window.isApplePayAvailable()) {
        reject(new Error('Apple Pay is not available on this device'));
        return;
      }

      // Создаем Braintree client
      braintree.client.create({
        authorization: clientToken
      }, function(clientErr, clientInstance) {
        if (clientErr) {
          reject(new Error('Failed to create Braintree client: ' + clientErr.message));
          return;
        }

        // Создаем Apple Pay instance
        braintree.applePay.create({
          client: clientInstance
        }, function(applePayErr, applePayInstance) {
          if (applePayErr) {
            reject(new Error('Failed to create Apple Pay instance: ' + applePayErr.message));
            return;
          }

          // Создаем payment request
          const request = applePayInstance.createPaymentRequest({
            total: {
              label: 'Power Bank Rental',
              amount: amount.toString()
            },
            currencyCode: 'USD',
            countryCode: 'US',
            requiredBillingContactFields: ['postalAddress'],
            requiredShippingContactFields: []
          });

          // Создаем Apple Pay session
          const session = new ApplePaySession(3, request);

          // Обработка merchant validation
          session.onvalidatemerchant = function(event) {
            // Отправляем запрос на backend для валидации merchant
            fetch('/api/v1/payments/validate-merchant', {
              method: 'POST',
              headers: {
                'Content-Type': 'application/json',
              },
              body: JSON.stringify({
                validationURL: event.validationURL
              })
            })
            .then(response => response.json())
            .then(data => {
              session.completeMerchantValidation(data);
            })
            .catch(error => {
              console.error('Merchant validation failed:', error);
              reject(new Error('Merchant validation failed'));
            });
          };

          // Обработка авторизации платежа
          session.onpaymentauthorized = function(event) {
            applePayInstance.tokenize({
              payment: event.payment
            }, function(tokenizeErr, payload) {
              if (tokenizeErr) {
                session.completePayment(ApplePaySession.STATUS_FAILURE);
                reject(new Error('Payment tokenization failed: ' + tokenizeErr.message));
                return;
              }

              session.completePayment(ApplePaySession.STATUS_SUCCESS);
              resolve(payload.nonce);
            });
          };

          // Обработка отмены
          session.oncancel = function() {
            reject(new Error('Apple Pay payment was cancelled'));
          };

          // Начинаем сессию
          session.begin();
        });
      });
    } catch (e) {
      reject(new Error('Apple Pay initialization failed: ' + e.message));
    }
  });
};