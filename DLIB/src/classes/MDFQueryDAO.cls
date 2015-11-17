/**
 * This is interface encapsulates the interaction with the "database".
 * The primary reason this exists is to make testability easier. The MetricsDataFile object
 * is not DML enabled, so there is no way to create test data. This allows us to provide a stub
 * impl when unit testing to return whatever data we want.
 */
public interface MDFQueryDAO {
	List<MetricsDataFile> findMDFs(String metricsType, String namespacePrefix, Date lookbackStartDate);
	
	List<MetricsDataFile> findMDFs(String sendingInstanceId, Date lookbackStartDate);
	
	Set<String> findNamespaces();
}