const functions = require('firebase-functions');
const admin = require('firebase-admin')
admin.initializeApp(functions.config().firebase);

exports.btcPriceNotification = functions.https.onRequest((req, res) => {

	const key = req.query.key;

	if (key != functions.config().btcpricenotif.key) {
		res.status(403).send("Wrong API key");
		return;
	}
	const ref = admin.database().ref();
	const devices = []

	ref.child('user_ids').child('users').once('value').then(snap => {
		snap.forEach(childSnap => {
			const device = childSnap.val();
			devices.push(device)
		});
		return devices;
	}).then(devices => {

		const payload = {
			notification: {
				body: 'Check out the Bitcoin Price! 😲',
				sound: 'default',
				badge: '1'
			}
		};

		var options = {
			priority: "high",
			timeToLive: 60 * 60 * 24 * 7
		};
		return admin.messaging().sendToDevice(devices, payload, options).then(() => {
			res.send("Successfully sent message");
		}).catch(error => {
			res.send(error);
		});
	});
});

exports.btcPriceNotificationLite = functions.https.onRequest((req, res) => {

	const key = req.query.key;

	if (key != functions.config().btcpricenotif.key) {
		res.status(403).send("Wrong API key");
		return;
	}
	const ref = admin.database().ref();
	const devices = []

	ref.child('user_ids_lite').child('users').once('value').then(snap => {
		snap.forEach(childSnap => {
			const device = childSnap.val();
			devices.push(device)
		});
		return devices;
	}).then(devices => {

		const payload = {
			notification: {
				body: 'Check out the Bitcoin Price! 😲',
				sound: 'default',
				badge: '1'
			}
		};

		var options = {
			priority: "high",
			timeToLive: 60 * 60 * 24 * 7
		};
		return admin.messaging().sendToDevice(devices, payload, options).then(() => {
			res.send("Successfully sent message");
		}).catch(error => {
			res.send(error);
		});
	});
});
