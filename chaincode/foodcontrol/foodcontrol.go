package main

import (
	"encoding/json"
	"fmt"
	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

type SmartContract struct {
	contractapi.Contract
}

//Activo
type Food struct {
	Farmer  string `json:"farmer"`
	Variety string `json:"variety"`
}

func (s *SmartContract) Set(ctx contractapi.TransactionContextInterface, foodId string, farmer string, variety string) error {

	food, err := Query(ctx, foodId)
	if food != nil {
		fmt.Printf("foodId already exists: %s", err.Error())
		return err
	}

	food := Food{
		Farmer:  farmer,
		Variety: variety,
	}

	foodAsBytes, err := json.Marshal(food)
	if err != nil {
		fmt.Printf("Error on json parse: %s", err.Error())
		return err
	}

	return ctx.GetStub().PutState(foodId, foodAsBytes)
}

func (s *SmartContract) Query(ctx contractapi.TransactionContextInterface, foodId string) (*Food, error) {

	foodAsBytes, err := ctx.GetStub().GetState(foodId)
	if err != nil {
		return nil, fmt.Errorf("Error retrieving food. %s", err.Error())
	}

	if foodAsBytes == nil {
		return nil, fmt.Errorf("Food not found:", foodId)
	}

	food := new(Food)
	err = json.Unmarshal(foodAsBytes, food)
	if err != nil {
		return nil, fmt.Errorf("Error retrieving food. %s", err.Error())
	}
	return food, nil
}

func main() {
	chaincode, err := contractapi.NewChaincode(new(SmartContract))
	if err != nil {
		fmt.Printf("Error create foodcontrol chaincode: %s", err.Error())
		return
	}

	if err := chaincode.Start(); err != nil {
		fmt.Printf("Error starting foodcontrol chaincode: %s", err.Error())
	}
}
