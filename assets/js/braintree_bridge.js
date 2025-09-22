window.initDropIn = function (clientToken, containerId) {
  return braintree.dropin.create({
    authorization: clientToken,
    container: '#' + containerId
  }).then(function (dropinInstance) {
    window._dropin = dropinInstance;
    return true;
  });
};

window.requestPaymentMethod = function () {
  return window._dropin.requestPaymentMethod().then(function (payload) {
    return payload.nonce; // передаём nonce в Flutter
  });
};
