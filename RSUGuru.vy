OwningCompany: public(address)              # Employers public wallet address
Employee: public(address)                   # Employees public wallet address
StockPrice: public(wei_value)               # Current stock price value (Static) --> in future iterations this value can be updated live via a web api
RSUValue: public(wei_value)                 # Value given to the employee for the entire vesting period
VestingPeriod: public(timedelta)            # time in seconds for vesting period, note: 31536000 seconds per year
PartialVestingPeriod : public(timedelta)    # time in seconds for partial vesting period
PartialVestingAmount : public(wei_value)    # amount for how much you can withdraw after partial vesting period
FullyVestedTimePassed : public(timestamp)   # timestamp for when the RSUs will be considered fully vested, and available for full withdraw
PartialVestedTimePassed : public(timestamp) # timestamp for when the RSUs will be considered partially vested, and available for partial withdraw


# Initializes all of our global variables
@payable
@public 
def __init__(_owningCompany: address, _employee: address, _vestingPeriod: timedelta, _partialVestingPeriod: timedelta, _partialVestingAmount: wei_value, _stockPrice: wei_value):
    self.OwningCompany = _owningCompany
    self.Employee = _employee
    self.StockPrice = _stockPrice
    self.RSUValue = msg.value
    self.VestingPeriod = _vestingPeriod
    self.PartialVestingPeriod = _partialVestingPeriod
    self.PartialVestingAmount = _partialVestingAmount
    self.FullyVestedTimePassed = block.timestamp + self.VestingPeriod
    self.PartialVestedTimePassed = block.timestamp + self.PartialVestingPeriod
    

# This function allows the employee to withdraw their partial vesting amount, given that the partial vesting period has elapsed.
@public
def Withdraw_Partial_Vesting_Amount():
    assert msg.sender == self.Employee
    assert block.timestamp >= self.PartialVestedTimePassed
    send(self.Employee, self.PartialVestingAmount)


# This function allows the employee to withdraw their full vested amount, given that the full vesting period has elapsed.
@public
def Withdraw_Full_Vested_Amount():
    assert msg.sender == self.Employee
    assert block.timestamp >= self.FullyVestedTimePassed
    selfdestruct(self.Employee)


# This function allows companies to withdraw the remaining contents of the contract, and selfdesruct in case of the employee being terminated.
@public
def Terminate_Employee():
    assert msg.sender == self.OwningCompany
    selfdestruct(self.OwningCompany)