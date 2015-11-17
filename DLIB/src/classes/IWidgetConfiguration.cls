public interface IWidgetConfiguration {
	String widgetType();
	String widgetNamespace();
	String widgetInstanceId();
	Map<String, Object> widgetPropertiesConfiguration();
}