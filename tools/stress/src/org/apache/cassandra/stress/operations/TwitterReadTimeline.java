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

public class TwitterReadTimeline extends Operation {
    private static final int kNumFollowers = 20;
    private static Random rand = new Random();

    public TwitterReadTimeline(Session session, int index) {
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

        ColumnParent parent = new ColumnParent("Timeline");
        List<ColumnOrSuperColumn> friends = null;

        SlicePredicate predicate = new SlicePredicate();
        SliceRange sliceRange = new SliceRange();
        sliceRange.setStart(new byte[0]);
        sliceRange.setFinish(new byte[0]);
        predicate.setSlice_range(sliceRange);

        long startNano = System.nanoTime();
        long start = System.currentTimeMillis();

        for (int t = 0; t < session.getRetryTimes(); t++) {
            try {
                friends = clientLibrary.get_slice(me, parent, predicate);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        session.operations.getAndIncrement();
        session.keys.getAndAdd(1);
        session.columnCount.getAndAdd(kNumFollowers);
        session.bytes.getAndAdd(100);
        session.latency.getAndAdd(System.currentTimeMillis() - start);
        long latencyNano = System.nanoTime() - startNano;
        session.lastLatency.set(latencyNano);
        session.latency.getAndAdd(latencyNano/1000000);
        session.latencies.add(latencyNano/1000);
    }
}
