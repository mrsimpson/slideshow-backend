// Setup type definitions for built-in Supabase Runtime APIs
/// <reference types="https://esm.sh/@supabase/functions-js/src/edge-runtime.d.ts" />
import {FunctionsHttpError, createClient} from "supabase"
import {Database, Tables} from "@database"

Deno.serve(async (req) => {
    try {
        const {presentation} = await req.json()
        if (!presentation) {
            throw new FunctionsHttpError("presentation not supplied")
        }
        const authHeader = req.headers.get('Authorization')!
        const supabase = createClient<Database>(
            Deno.env.get('SUPABASE_URL') ?? '',
            Deno.env.get('SUPABASE_ANON_KEY') ?? '',
            {global: {headers: {Authorization: authHeader}}}
        )
        const token = authHeader.split(' ')[1]
        const {data: {user}} = await supabase.auth.getUser(token)
        if (!user) {
            console.log(authHeader)
            throw new FunctionsHttpError("consumer not authenticated")
        }

        const startedEvent = await supabase
            .from("presentation_events")
            .insert({presentation, type: "presentation_start", created_by: user.id})
            .select()

        return new Response(
            JSON.stringify(startedEvent),
            {headers: {"Content-Type": "application/json"}},
        )
    } catch (error) {
        throw new FunctionsHttpError(error)
    }
})
