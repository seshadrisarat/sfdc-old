global class FilteredDealer implements Comparable {

  public final Integer index {get; private set;}
  public final Id id {get; private set;}

  public FilteredDealer(Id dealerId, Integer index) {
    this.id = dealerId;
    this.index = index;
  } 
   
  global Integer compareTo(Object compareTo) {
    FilteredDealer dealer = (FilteredDealer)compareTo;
    if(index == dealer.index) return 0;
    if(index > dealer.index) return 1;
    return -1;      
  }  
  
}