Linguistic Explorer Search Algorithm (proposed)
===============================================

Detailed Flow of a Query:

Check for invalid combinations, e.g. all on some selector box and
Example clicked. That is invalid.

A) Keyword Search on LingsProperty
Fold any keyword searches on lingpropval into their appropriate selector box, e.g. a keyword search on word initial "G" for ling name will be a selection on Greek and German among others (if lings are languages). This will be intersected with any other selections in that selector box to give a net set of selections.

B) Find Selected Lings, Properties, LingsProperty (ANY)
Perform disjunctions ("any") from selection boxes. (If there are conjunctions ("all") treat these as disjunctions ("any") for the purposes of this step. This saves work for later.)

C) Filters
Each such disjunction gives a set of LingPropVal rows. They may be at different depths, e.g. sentence-property-value, speaker-property-value. So we need to tie these together.

C1) LingsProperty by Ling Depth
First intersect rows having lingids at the same depth. This gives a set of LingPropVal rows at each depth.

C2) LingsProperty by Ling Parent ID
Tie together the rows at different depths based on Ling.parentid. This can give a join result having more than three columns. In the result, a row concerning a sentence survives only if the speaker of that sentence survives the demographic query and a row concerning a speaker survives only if a sentence survives the linguistic query.

D) Showing Criteria
D1) Keyword Search on Example (if showing examples)
If examples are clicked, then join with the results of the LingPropVal queries based on LingPropValID and filter further based on keyword searches on example attributes.

D2) Group By (ALL)
If all is clicked for at least one selection box, then perform a group by on the fields of the ShowClickboxes. Call those fields the ShowFields. This group by is unusual in that there are no aggregates. Instead, for each distinct value of the ShowFields (i.e. each
distinct combination of values), we associate a vector of values for each field F on which there is an all. So, for each such distinct value combination c, we have a vector v of F values. We check whether the selected F values in the selector box is a subset of v. If so, then c passes into the solution. Otherwise, it doesn't.

E) Link up with attributes table based on lingid and possibly exampleid as appropriate. Order by language-property.

F) Advanced Features are mutually exclusive and can all be handled as a postprocessing step.

1. Cross between P1 and P2:
Just take the result and enumerate all possible values for P1 and P2.
For each combination of P1.value and P2.value, take the maximum depth lings.
The list of lings associated with each P1-v1, P2-v2 pair is the result
of the cross.
Find the latlongs for those to send to the mapper.

2. To compare languages L1 and L2, just take the results and produce a list
of common property-values as well as the
property values that one has but the other doesn't.

3. To create a similarity tree, take result and convert it to hierarchical
clustering (works for yes/no/NA using hamming distance as currently
implemented, but
could also work using a Jaccard measure (not yet implemented)).

4. The only tricky one is implications. If we choose "both" then we can handle as a pure postprocessing step using whichever LingPropVal result we get from C2. Otherwise, we have to do a second query. The basic algorithm is that we have one set of ling-prop-vals L1 and another set of ling-prop-vals L2. (They are the same if the user selects the both option, but not otherwise. In particular, if the user selects Antecedent, then the result of step C2 is L1 and L2 is the entire LingPropVal table. If the user selects Consequent, then the result of step C2 is L2 and L1 is the entire LingPropVal table.) An implication P1.v1 ==> P2.v2 holds if whenever P1.v1 is associated with a ling (of any depth) and P2 is also associated with the ling, then P2 is associated with exactly one value v. We are most interested in such implications that happen very often and those that happen never. 

Here is the basic query form:

for each ling x in L2,
if property P2 has exactly one value v2, then for every other
property-value pair P1.v1 associated with ling in L1,
add x to the list associated with P1.v1, P2.v2.
If there is ever a "contradiction", i.e. a language where
P1.v1, P2.v2' holds and v2 != v2', then just mark the lists of both
P1.v1, P2.v2 and P1.v1, P2.v2' as
invalid and stop appending to those lists.
At the end, sort by length of list of valid
pairs and present just the number
of languages for which each implications holds.
If that number is clicked, the languages should appear.

5. Another advanced feature that we don't have is to save
the results of queries and to do AND/OR/DIFFERENCE on them
if they have the same columns.
This is straightforward.
