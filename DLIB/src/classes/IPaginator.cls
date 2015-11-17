public interface IPaginator {
	void firstRecords();
	void lastRecords();
	void nextRecords();
	void prevRecords();
	void goToPage();
}