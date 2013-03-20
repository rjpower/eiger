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

public class TwitterPopulator extends Operation
{
    private static ArrayList<ByteBuffer> values;
    private static ArrayList<Integer> columnCountList;

    public TwitterPopulator(Session session, int index)
    {
        super(session, index);
    }

    @Override
    public void run(Cassandra.Client client) throws IOException
    {
        throw new RuntimeException("Dynamic Workload must be run with COPS client library");
    }

    @Override
    public void run(ClientLibrary clientLibrary) throws IOException
    {
			//insert 1 million friends, each with 20 followers
			int numUsers = 10;
			for (int  i = 0; i < numUsers; i++) {
					
			}
    }

}
