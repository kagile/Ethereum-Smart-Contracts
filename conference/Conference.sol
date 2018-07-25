pragma solidity ^0.4.24;
import "./SafeMath.sol";

/**
* This contract is for public Conferences. 
* To keep rules simple, there is one organizer who organizes the conference.
* There is a quota of maximum 100 seats initially.
* Also, if someone asks for a refund, he/she can request cancellation to the organizer and only organizer can provide the refund.
*/
contract Conference {

	using SafeMath for uint256;

	address  organizer;
	mapping (address => uint)  registrantsPaid; //mapping of attendee and his amount sent
	uint  numRegistrants; //total number of registrations
	uint  quota; //maximum seats available
	uint ticketPrice; //price of a single ticket

	event Deposit(address _from, uint _amount); //when the ticket is bought, this event will be fired
	event Refund(address _to, uint _amount); //when the refund is given, this event will be fired

	/**
	 * this modifier will restrict opertaions to be done only by organizer.
	 */
	modifier restricted() {
	 require (msg.sender == organizer);
	 _;
	}

	 constructor() public {
		organizer = msg.sender;		
		quota = 100; //initial quota is 100. it can be changed using external function.
		numRegistrants = 0;
		ticketPrice = 0.1 ether; //ticet price is 0.1 ether and it can not be changed once the contract is published
	}

	/**
	* function for buying tickets. it will check the amount sent by sender, quota and whether user has already bought the ticket or not.
	*/
	function buyTicket() external payable {
	    require(msg.value == ticketPrice,"Received amount is not equal to ticket price");
		require (numRegistrants <= quota,"Quota full. No tickets left"); 
		require(registrantsPaid[msg.sender] == 0,"You have already bought ticket");
		registrantsPaid[msg.sender] = msg.value;
		numRegistrants.add(1);
		emit Deposit(msg.sender, msg.value);
	}

	function getTicketPrice() view external returns(uint)   {
	        return ticketPrice;
	}


	function changeQuota(uint _newquota) external restricted {
		quota = _newquota;
	}

	/**
	* function for providing refund. It can only be done by the organizer.
	* It will also check the ownership of ticket and balance of organizer.
	* After that, it will transfer the refund amount to the attendee who has requested for refund.
	*/
	function refundTicket(address _recipient) external payable restricted {
		require (registrantsPaid[_recipient] == ticketPrice, "You have not paid anything");
		address myAddress = this;
		require (myAddress.balance >= ticketPrice,"No balance in organizer's account"); 
		_recipient.transfer(ticketPrice);
		emit Refund(_recipient, ticketPrice);
		registrantsPaid[_recipient] = 0;
		numRegistrants.sub(1);
	}

	function destroy() external restricted {
		selfdestruct(organizer); //contract can be destroyed so that the organizer gets all the amount gathered.
	}
}
