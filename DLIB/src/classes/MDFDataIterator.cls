/**
 *
 */
public with sharing class MDFDataIterator implements Iterable<MDFDataModel> {
	
	private MDFLineFilter lineFilter;
	private MDFDataLineParser lineParser;
	private String mdfContent;
	
	public MDFDataIterator(MDFLineFilter lineFilter, MDFDataLineParser lineParser, MetricsDataFile mdf) {
		/* a lineFilter is optional, if null is provided every model will "match" */
		this.lineFilter = lineFilter;
		
		/* a lineParser is required */
		if (lineParser == null) {
			throw new MDFDataIteratorException('A MDFLineParser is required');
		}
		this.lineParser = lineParser;
		
		/* it really doesn't make sense to try to iterate through an null / empty MetricsDataFile, but it won't cause any problems */
		if (mdf != null && mdf.MetricsDataFileLength > 0 && mdf.MetricsDataFile != null) {
			this.mdfContent = mdf.MetricsDataFile.toString();
			//System.debug('mdfContent=' + this.mdfContent);	
		}
		else {
			this.mdfContent = null;
		}
	}
	
	public Iterator<MDFDataModel> iterator() {
		return new TheIterator(this);
	}
	
	private class TheIterator implements Iterator<MDFDataModel> {
		
		private MDFDataIterator parent;
		
		private Integer beginIndex = 0;
		private Integer endIndex = 0;
		
		private Boolean hasNextCalled = false;
		private MDFDataModel nextModel = null;
		
		/**
		 * Create our actual iterator with a reference to the MDFDataIterator
		 * (Apex doesn't allow direct access to the outer class as java does - 
		 * ie: MDFDataIterator.this.mdfContent does not work)
		 */
		private TheIterator(MDFDataIterator parent) {
			this.parent = parent;
		}

		public Boolean hasNext() {
			if (!hasNextCalled) {
				this.nextModel = findNextModel();	
			}
			
			this.hasNextCalled = true;
			
			return this.nextModel != null;
		}
		
		public MDFDataModel next() {
			if (!hasNextCalled) {
				this.nextModel = findNextModel();
			}
			
			this.hasNextCalled = false;
			
			return this.nextModel;
		}
		
		/**
		 * Handle the scanning through the big mdfContent string, looking for the next
		 * valid (according to the filter) MDFDataModel.
		 */
		private MDFDataModel findNextModel() {
			System.debug('looking for next model object in [' + parent.mdfContent + '], beginIndex=' + this.beginIndex);
			
			this.endIndex = parent.mdfContent != null ? parent.mdfContent.indexOf('\n', this.beginIndex) : -1;
			
			/* are we at the end? */
			if (this.endIndex == -1) {
				return null;
			}
			
			/* there's more data to process */
			MDFDataModel returnModel = null;
			do {
				String line = parent.mdfContent.substring(this.beginIndex, this.endIndex);
				System.debug('pulled out line [' + line + '] to convert into model');
				MDFDataModel model = parent.lineParser.createModelFromLine(line);
				System.debug('parsed model [' + model + ']');
				/* is this a model we're interested in? */
				if (parent.lineFilter == null || parent.lineFilter.matches(model)) {
					returnModel = model;
				}
				
				/* move the pointers forward */
				this.beginIndex = this.endIndex + 1;
				this.endIndex = parent.mdfContent.indexOf('\n', this.beginIndex);
			} 
			while (returnModel == null && this.endIndex != -1);
			
			return returnModel;
		}
	}
	
	public class MDFDataIteratorException extends Exception {
		
	}
}