#!/bin/bash
sleep=1

NPROC=(`nproc`)
for (( i = 0; i < $NPROC; i++ )); do
((sedline=i+2))
procstat_t1=(`cat /proc/stat | grep '^cpu' |sed -n "$sedline,$sedline p"`)
user_t1[$i]=${procstat_t1[1]}
nice_t1[$i]=${procstat_t1[2]}
system_t1[$i]=${procstat_t1[3]}
idle_t1[$i]=${procstat_t1[4]}
iowait_t1[$i]=${procstat_t1[5]}
irq_t1[$i]=${procstat_t1[6]}
softirq_t1[$i]=${procstat_t1[7]}
steal_t1[$i]=${procstat_t1[8]}
guest_t1[$i]=${procstat_t1[9]}
guest_nice_t1[$i]=${procstat_t1[10]}
((total_t1[$i]=user_t1[$i]+nice_t1[$i]+system_t1[$i]+idle_t1[$i]+iowait_t1[$i]+irq_t1[$i]+softirq_t1[$i]+steal_t1[$i]+guest_t1[$i]+guest_nice))
done

sleep $sleep

for (( i = 0; i < $NPROC; i++ )); do
((sedline=i+2))
procstat_t2=(`cat /proc/stat | grep '^cpu' |sed -n "$sedline,$sedline p"`)
user_t2[$i]=${procstat_t2[1]}
nice_t2[$i]=${procstat_t2[2]}
system_t2[$i]=${procstat_t2[3]}
idle_t2[$i]=${procstat_t2[4]}
iowait_t2[$i]=${procstat_t2[5]}
irq_t2[$i]=${procstat_t2[6]}
softirq_t2[$i]=${procstat_t2[7]}
steal_t2[$i]=${procstat_t2[8]}
guest_t2[$i]=${procstat_t2[9]}
guest_nice_t2[$i]=${procstat_t2[10]}
((total_t2[$i]=user_t2[$i]+nice_t2[$i]+system_t2[$i]+idle_t2[$i]+iowait_t2[$i]+irq_t2[$i]+softirq_t2[$i]+steal_t2[$i]+guest_t2[$i]+guest_nice))
done

for (( i = 0; i < $NPROC; i++ )); do
((user_subtracted[$i]=user_t2[$i]-user_t1[$i]))
((nice_subtracted[$i]=nice_t2[$i]-nice_t1[$i]))
((idle_subtracted[$i]=idle_t2[$i]-idle_t1[$i]))
((system_subtracted[$i]=system_t2[$i]-system_t1[$i]))
((iowait_subtracted[$i]=iowait_t2[$i]-iowait_t1[$i]))
((irq_subtracted[$i]=irq_t2[$i]-irq_t1[$i]))
((softirq_subtracted[$i]=softirq_t2[$i]-softirq_t1[$i]))
((steal_subtracted[$i]=steal_t2[$i]-steal_t1[$i]))
((guest_subtracted[$i]=guest_t2[$i]-guest_t1[$i]))
((guest_nice_subtracted[$i]=guest_nice_t2[$i]-guest_nice_t1[$i]))
((total_subtracted[$i]= total_t2[$i]-total_t1[$i]))
done

#Simple output
for (( i = 0; i < $NPROC; i++ )); do
((pcpu[$i]= 100 * (total_subtracted[$i]-idle_subtracted[$i]) / total_subtracted[$i]))
echo -e cpu$i "\t" ${pcpu[$i]}%
done

# Get the list of processes and sort them by most cpu usage
ps_output="$(ps aux)"
cpu_top_processes="$(printf "%s\\n" "${ps_output}" | awk '{print $2, $3"%", $11}' | sort -k2rn | head -3 | awk '{print "ID: "$1, $3, "\t"$2}')"

echo -e "========= Top CPU Processes =========
$cpu_top_processes"
