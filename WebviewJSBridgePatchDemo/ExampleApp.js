defineClass('ExampleUIWebViewController', {
    testObjcCallbacks: function() {
        var alertView = require('UIAlertView').alloc().initWithTitle_message_delegate_cancelButtonTitle_otherButtonTitles("Alert","原生并不存在的方法", self, "OK",  null);
        alertView.show();
    }
})
