import Notification from "../model/notification.model";
import Notifier from "./notifier";
import Cron from "cron";

class Scheduler {
    static initialize() {
        const job = new Cron.CronJob({
            cronTime: '0 * * * *',
            onTick: () => {
                Notification.aggregate([
                    {
                        $match: {createDate: {$gt: new Date(Date.now() - 60 * 60 * 1000)}}
                    },
                    {
                        $sort: {email: 1, timestamp: -1}
                    },
                    {
                        $group: {
                            _id: {email: '$email', name: '$name'},
                            notifications: {$push: "$$ROOT"}
                        }
                    },
                ], (err, result) => {
                    if (err) {
                        console.error(`Error occurred during getting notification from database. ${err}`);
                    } else {
                        result.forEach((res) => {
                            Notifier.notify(res._id.email, res._id.name, res.notifications)
                        });
                    }
                })
            },
            start: false,
            timeZone: 'Europe/Berlin'
        });
        job.start();
    }
}

export default Scheduler;