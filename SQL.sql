
use Assignment

<--Question01-->
create view showMaximum
AS
select top 3 a.balance, c.cusName, br.name, br.registration, a.balance
from BankCustomer c, Branch br, Bank b, Account a, belongsTo bt
where b.name='BOC' and  br.bCode =b.bankCode 
and b.bankCode=a.bCode and bt.accountNo=a.accNo 
and bt.cusNo = a.accNo 
order by a.balance

<--Question 02-->
create view TotalAmount
AS
select sum(t.amount)
from accountTransation act, AccType ty, Transact t
where t.tID = act.tid
and act.accNo= ty.accCode


<--Question 03-->
CREATE function TotalAccBalance(@brCode varchar(50),@bCode varchar(20))
returns float
AS
begin
declare @totalEarning float
SELECT @totalEarning=sum(a.balance)
FROM account a
WHERE a.bCode=@brCode and a.brCode=@bCode
return @totalEarning
end;

declare @result float
exec @result=TotalAccBalance 'BR123''B001'
print @result

<--Question 04-->
CREATE function TotalWithdrawals(@method varchar(50),@year int,@type varchar(20))
returns float
AS
begin
declare @totalWithdraw float
SELECT @totalWithdraw = sum(t.amount)
FROM accountTransation act,Transact t,AccType ty
WHERE act.tid=t.tID  and  t.dateTimeTrans=@year and
act.typeTrans=@method and ty.accDesc=@type
return @totalWithdraw
end;

<--Question 05-->
create procedure updateAcc(@money float, @operation varchar(50), @accNo varchar(20))
as 
begin
declare @newBal float

if(@operation=='debit')
	begin
	@newBal= select balance from Account - @money;
	update Account 
	set balance = @newBal
	where accNo=@accNo
	end
else if(@operation='credit')
	begin
	@newBal=select balance from Account + @money;
	update Account 
	set balance = @newBal
	where accNo=@accNo
	end
end;


<--Question 06-->

create procedure checkCapabilty(@senderAccNo varchar(20), @receiverAccNo varchar(20),@amount float)
as 
begin
declare @newRecBal float
declare @newSenBal float
@newRecBal=select balance from Account where accNo = @receiverAccNo + @amount;
	update Account 
	set balance = @newRecBal
	where accNo=@receiverAccNo
@newSenBal=select balance from Account where accNo = @senderAccNo - @amount;
	update Account 
	set balance = @newSenBal
	where accNo=@senderAccNo
end;


<--Question 07-->
create trigger checkBalance
on Account
for insert
as
begin
declare @balance float
declare @accNo varchar(20)
@balance = select @accNo=a.accNo
from Account a
exec @balance=updateAcc(@balance,'withdraw',@accNo)
if (@balance<500)
	rollback transaction
end;

<--Question 08-->
create trigger withLimit
on Transact
for insert
as
begin
declare @amount float
declare @accNo varchar(20)
@amount = select sum(t.amount )
from Transact t, accountTransation act
where t.dateTimeTrans=GETDATE() 
and act.tid=t.tID and act.accNo =@accNo

if (@amount > 80000)
	rollback transaction
end;


