package org.apache.cassandra.stress.operations;

import java.io.IOException;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;

import org.apache.cassandra.client.ClientLibrary;
import org.apache.cassandra.stress.Session;
import org.apache.cassandra.stress.util.Operation;
import org.apache.cassandra.thrift.Cassandra;
import org.apache.cassandra.thrift.Column;
import org.apache.cassandra.thrift.ColumnOrSuperColumn;
import org.apache.cassandra.thrift.ColumnParent;
import org.apache.cassandra.thrift.Mutation;
import org.apache.cassandra.thrift.SlicePredicate;
import org.apache.cassandra.thrift.SliceRange;
import org.apache.cassandra.utils.FBUtilities;

public class TwitterWorkload extends Operation {
    private static final int kNumFollowers = 20;
    private static Random rand = new Random();

    public TwitterWorkload(Session session, int index) {
        super(session, index);
    }

    @Override
    public void run(Cassandra.Client client) throws IOException {
        throw new RuntimeException(
                "Dynamic Workload must be run with COPS client library");
    }

    @Override
    public void run(ClientLibrary clientLibrary) throws IOException {
        // Each row is a record for a user.
        Map<ByteBuffer, Map<String, List<Mutation>>> records = new HashMap<ByteBuffer, Map<String, List<Mutation>>>();

        ByteBuffer me = ByteBuffer.wrap(String.format("user-%09d",
                rand.nextInt(session.getNumTotalKeys())).getBytes());

//        System.out.println("ME: " + new String(me.array()));
        ColumnParent parent = new ColumnParent("Followers");
        List<ColumnOrSuperColumn> friends = null;

        SlicePredicate predicate = new SlicePredicate();
        SliceRange sliceRange = new SliceRange();
        sliceRange.setStart(new byte[0]);
        sliceRange.setFinish(new byte[0]);
        predicate.setSlice_range(sliceRange);

        for (int t = 0; t < session.getRetryTimes(); t++) {
            try {
                friends = clientLibrary.get_slice(me, parent, predicate);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        ByteBuffer tweetId = ByteBuffer.wrap(String.format("tweet-id-%d-%d",
                rand.nextInt(), rand.nextInt()).getBytes());

        HashMap<ByteBuffer, Map<String, List<Mutation>>> updates = new HashMap<ByteBuffer, Map<String, List<Mutation>>>();
        // for each friend add my tweet to their what?

        for (ColumnOrSuperColumn f : friends) {
            ByteBuffer rowName = ByteBuffer.wrap(f.getColumn().getName());

            Column c = new Column();
            c.setName(tweetId);
            c.setValue(me);
            c.setTimestamp(FBUtilities.timestampMicros());

            ArrayList<Mutation> timelineUpdates = new ArrayList<Mutation>();
            ColumnOrSuperColumn column = new ColumnOrSuperColumn().setColumn(c);
            timelineUpdates
                    .add(new Mutation().setColumn_or_supercolumn(column));

            HashMap<String, List<Mutation>> mutations = new HashMap<String, List<Mutation>>();
            mutations.put("Timeline", timelineUpdates);
            updates.put(rowName, mutations);
        }

        // Add a tweet
        {
            Map<String, List<Mutation>> tweets = new HashMap<String, List<Mutation>>();
            List<Mutation> tweetMutation = new ArrayList<Mutation>();
            Mutation m = new Mutation();
            Column c = new Column();
            c.setName(tweetId);
            c.setValue(ByteBuffer
                    .wrap("11111111111111111111111111111111111111111111111111111112."
                            .getBytes()));
            c.setTimestamp(FBUtilities.timestampMicros());
            m.setColumn_or_supercolumn(new ColumnOrSuperColumn().setColumn(c));
            tweetMutation.add(m);
            tweets.put("Tweets", tweetMutation);
            updates.put(me, tweets);

//            System.out.println("Tweet mutation:" + m.toString());
        }

        long start = System.currentTimeMillis();

        boolean success = false;
        String exceptionMessage = null;

        for (int t = 0; t < session.getRetryTimes(); t++) {
            if (success)
                break;

            try {
                clientLibrary.transactional_batch_mutate(updates);
                success = true;
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        session.operations.getAndIncrement();
        session.keys.getAndAdd(1);
        session.columnCount.getAndAdd(kNumFollowers);
        session.bytes.getAndAdd(100);
        session.latency.getAndAdd(System.currentTimeMillis() - start);
    }
}
