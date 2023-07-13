import React from 'react'
import { createGlobalState } from 'react-hooks-global-state'
import moment from "moment";
import { fromJSON } from 'postcss';

const {setGlobalState, getGlobalState, useGlobalState} = createGlobalState({
    createModal : "scale:0",
    connectAccount:"",
    contract:null,
    proposals:[],
    isStakeholder:false,
    balance:0,
    myBalance:0,
})

const truncate = (text, startChar, endChar,maxLength) => {
    if(text.length > maxLength) {
        let start = text.subString(0, startChar)
        let end = text.subString(text.length-endChar, text.length)
        while(start.length+end.length) {
            start=start+="."
        }
        return start+end
    }
    return text
}

const daysRemaining = (days) => {
    const todaysDate = moment()
    days = Number((days+'000').slice(0))
    days = moment(days).format('YYY-MM-DD')
    days = moment(days)
    days = days.diff(todaysDate, "days")
    return days==1 ? "1 day" : `${days} days`
}

export {
    truncate,
    setGlobalState,
    useGlobalState,
    getGlobalState,
    daysRemaining
}