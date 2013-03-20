package org.apache.cassandra.stress.operations;

import java.io.IOException;
import java.nio.ByteBuffer;
import java.util.*;

import org.apache.cassandra.client.ClientLibrary;
import org.apache.cassandra.stress.Session;
import org.apache.cassandra.stress.Stress;
import org.apache.cassandra.stress.util.Operation;
import org.apache.cassandra.thrift.Cassandra;
import org.apache.cassandra.thrift.Column;
import org.apache.cassandra.thrift.ColumnOrSuperColumn;
import org.apache.cassandra.thrift.Mutation;
import org.apache.cassandra.utils.ByteBufferUtil;
import org.apache.cassandra.utils.FBUtilities;

public class TwitterPopulator extends Operation {
    private static final int kNumFollowers = 20;
    private static Random rand = new Random();

    public TwitterPopulator(Session session, int index) {
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

        ByteBuffer me = ByteBuffer.wrap(String.format("user-%09d", index)
                .getBytes());

        // create follower entries
        ArrayList<Mutation> followerMutations = new ArrayList<Mutation>();
        for (int i = 0; i < kNumFollowers; ++i) {
            String friend = String.format("user-%09d",
                    rand.nextInt(session.getNumTotalKeys()));
            
            Column c = new Column();
            c.setName(friend.getBytes());
            c.setValue("1".getBytes());
            c.setTimestamp(FBUtilities.timestampMicros());

            ColumnOrSuperColumn column = new ColumnOrSuperColumn().setColumn(c);
            followerMutations.add(new Mutation().setColumn_or_supercolumn(column));
        }

        HashMap<String, List<Mutation>> mutations = new HashMap<String, List<Mutation>>();
        mutations.put("Followers", followerMutations);
        
        HashMap<ByteBuffer, Map<String, List<Mutation>>> updates = new HashMap<ByteBuffer, Map<String, List<Mutation>>>();
        updates.put(me, mutations);

        long start = System.currentTimeMillis();

        boolean success = false;
        String exceptionMessage = null;

        for (int t = 0; t < session.getRetryTimes(); t++) {
            if (success)
                break;

            try {
                clientLibrary.batch_mutate(updates);
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
