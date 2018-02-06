import Mongo from './lib/mongo';
import QueueConsumer from './lib/consumer';
import Scheduler from './lib/scheduler';

Mongo.connect();

QueueConsumer.initialize();
Scheduler.initialize();