public class report_auth_controller {

    public String getHostUrl() {
        return ApexPages.currentPage().getHeaders().get('Host');
    }
}