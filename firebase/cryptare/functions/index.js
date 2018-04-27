const functions = require('firebase-functions');
const admin = require('firebase-admin')

var serviceAccount = require('./service_account_info/Cryptare-9d04b184ba96.json');

admin.initializeApp({
	credential: admin.credential.cert(serviceAccount),
	databaseURL: 'https://atalwcryptare.firebaseio.com/'
});


// For the best performance, only request data at the deepest level possible.
exports.coinAlerts = functions.database.ref('/coin_alerts/{uid}/{market}/{coin}/{currency}/{count}/current_price')
	.onUpdate((change, context) => {
		const uid = context.params.uid;
		const market = context.params.market;
		const coin = context.params.coin;
		const currency = context.params.currency;
		const count = context.params.count;

		const before_price = change.before.val();
		const current_price = change.after.val();

		// if (before_price == current_price) {
		// 	return console.log('value has not changed')
		// }

		return change.after.ref.parent.child('isActive').once('value').then(snap => {
			const isActive = snap.val();
			if (isActive) {
				return change.after.ref.parent.child('thresholdPrice').once('value').then(snap => {
					const notification_price = snap.val();
					return change.after.ref.parent.child('isAbove').once('value').then(snap => {
						const isAbove = snap.val();
						var fire_notification = false

						if (isAbove) {
							if (current_price > notification_price) {
								fire_notification = true
							}
						}
						else {
							if (current_price < notification_price) {
								fire_notification = true
							}
						}

						if (fire_notification) {
							// Get the list of device notification tokens.
							const getDeviceTokensPromise = admin.database()
							.ref(`/users/${uid}/notificationTokens`).once('value');

					 		// The snapshot to the user's tokens.
					 		let tokensSnapshot;

      				// The array containing all the user's tokens.
      				let tokens;

      				return Promise.all([getDeviceTokensPromise]).then(results => {

      					tokensSnapshot = results[0];
								// Check if there are any device tokens.
								if (!tokensSnapshot.hasChildren()) {
									return console.log('There are no notification tokens to send to.');
								}

								console.log('There are', tokensSnapshot.numChildren(), 'tokens to send notifications to.');

								const title_text = `Price alert for ${market} (${coin}/${currency})`
								var body_text = ''

								if (isAbove) {
									body_text = `📈 The price is ${current_price}, above your set threshold of ${notification_price}`
								}
								else {
									body_text = `📉 The price is ${current_price}, below your set threshold of ${notification_price}`
								}

								const payload = {
									notification: {
										title: title_text,
										body: body_text,
										sound: 'default',
										badge: '1'
									}
								};

								var options = {
									priority: "high",
									timeToLive: 60 * 60 * 24 * 7
								};

								tokens = Object.keys(tokensSnapshot.val());

								change.after.ref.parent.update({'isActive': false})

								return admin.messaging().sendToDevice(tokens, payload, options);
							}).then((response) => {
								const tokensToRemove = [];
								response.results.forEach((result, index) => {
									const error = result.error;
									if (error) {
										console.error('Failure sending notification to', tokens[index], error);
            					// Cleanup the tokens who are not registered anymore.
            					if (error.code === 'messaging/invalid-registration-token' ||
            						error.code === 'messaging/registration-token-not-registered') {
            						tokensToRemove.push(tokensSnapshot.ref.child(tokens[index]).remove());
            				}
            			}
            		});
								return Promise.all(tokensToRemove);
							});
						}
						else {
							return console.log('dont fire notif', current_price);
						}
					});
				});
			}
			else {

			}
		});
	});

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
				body: 'Check out the Bitcoin Price! 😲🤑',
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
				body: 'Check out the Bitcoin Price! 😲🤑',
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