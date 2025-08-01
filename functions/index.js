const functions = require(
    'firebase-functions'
)
const admin = require(
    'firebase-admin'
)
admin.initializeApp();

exports.sendAppointmentNotification = functions.firestore.document('appointments/{appointmentsId}').onCreate(async (snap, context) => {
    const appointment = snap.data();

    // References for doctor and patient
    const doctorRef = admin.firestore().collection('doctors').doc(appointment.doctorID);
    const patientRef = admin.firestore().collection('patients').doc(appointment.patientID);

    // Defining both variables at the same time (async) using destructuring (also very cool)
    // each one holds the actual data of the reference above
    const [doctorDoc, patientDoc] = await Promise.all([
        doctorRef.get(),
        patientRef.get()
    ]);

    if (!doctorDoc.exists || !patientDoc.exists) {
        console.error('Doctor or patient document does not exist');
        return;
    }

    // Tokens
    const doctorToken = doctorDoc.data().fcmToken;
    const patientToken = patientDoc.data().fcmToken;

    // Names
    const doctorName = doctorDoc.data().name;
    const patientName = patientDoc.data().name;

    // Messages
    const doctorMessage = {
        notification: {
            title: "موعد جديد!",
            body: `لديك موعد جديد مع ${patientName}`
        }
    }

    const patientMessage = {
        notification: {
            title: "موعد جديد!",
            body: `تم حجز موعدك مع الدكتور ${doctorName}`
        }
    }

    // Send the messages with the tokens
    const responses = [];

    if (doctorToken) {
        responses.push(admin.messaging().send({ ...doctorMessage, token: doctorToken }));
    }
    if (patientToken) {
        responses.push(admin.messaging().send({ ...patientMessage, token: patientToken }));
    }

    // For debugging
    console.log('Sending notification to doctor:', doctorName);
    console.log('Sending notification to patient:', patientName);

    return Promise.all(responses);
})


