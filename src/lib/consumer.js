import Consumer from 'sqs-consumer';
import Notification from "../model/notification.model";

class QueueConsumer {
    static initialize() {
        const app = Consumer.create({
            queueUrl: process.env.NOTIFICATION_SQS_URL,
            handleMessage: (message, done) => {
                const notificationModel = new Notification(JSON.parse(JSON.parse(message.Body).Message));
                notificationModel.save((err) => {
                    if (err) {
                        console.error(`Error occurred while saving notification. ${err}`);
                    }
                });
                done();
            }
        });

        app.on('error', (err) => {
            console.log(err.message);
        });

        app.start();
    }
}

export default QueueConsumer;