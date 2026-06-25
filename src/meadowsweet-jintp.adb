with Servlet.Streams;
with Jintp;

package body Meadowsweet.Jintp is

   type Inspectable_Bean_Access is access all Meadowsweet.Inspectable_Bean;

   procedure To_Dictionary (Source : Meadowsweet.Inspectable_Bean'Class;
                            Target : in out Standard.Jintp.Dictionary);

   procedure To_List (Source : Object;
                      Target : in out Standard.Jintp.List) is
      Length : constant Natural := Get_Count (Source);
      Value : Object;
   begin
      for I in 1 .. Length loop
         Value := Get_Value (Source, I);
         case Get_Type (Value) is
            --  currently not supported by JinTP
            --  when TYPE_BOOLEAN =>
            --      Target.Append (To_Boolean (Value));
            --  when TYPE_INTEGER =>
            --      Target.Append (To_Integer (Value));
            --  when TYPE_FLOAT =>
            --      Target.Append (To_Long_Float (Value));
            when TYPE_BEAN =>
               declare
                  D : Standard.Jintp.Dictionary;
               begin
                  To_Dictionary (Inspectable_Bean_Access (To_Bean (Value)).all,
                                 D);
                  Target.Append (D);
               end;
            when TYPE_ARRAY =>
               declare
                  L : Standard.Jintp.List;
               begin
                  To_List (Value, L);
                  Target.Append (L);
               end;
            when others =>
               Target.Append (To_String (Value));
         end case;
      end loop;
   end To_List;

   procedure To_Dictionary (Source : Meadowsweet.Inspectable_Bean'Class;
                            Target : in out Standard.Jintp.Dictionary) is
      Property_Names : constant Meadowsweet.String_Array
        := Source.Property_Names;
      Value : Object;
      Value_Type : Data_Type;
   begin
      for I in Property_Names'Range loop
         Value := Source.Get_Value (To_String (Property_Names (I)));
         Value_Type := Get_Type (Value);
         case Value_Type is
            when TYPE_BOOLEAN =>
               Target.Insert (Property_Names (I), To_Boolean (Value));
            when TYPE_INTEGER =>
               Target.Insert (Property_Names (I), To_Integer (Value));
            when TYPE_FLOAT =>
               Target.Insert (Property_Names (I), To_Long_Float (Value));
            when TYPE_BEAN =>
               declare
                  D : Standard.Jintp.Dictionary;
               begin
                  To_Dictionary (Inspectable_Bean_Access (To_Bean (Value)).all,
                                 D);
                  Target.Insert (Property_Names (I), D);
               end;
            when TYPE_ARRAY =>
               declare
                  L : Standard.Jintp.List;
               begin
                  To_List (Value, L);
                  Target.Insert (Property_Names (I), L);
               end;
            when others =>
               Target.Insert (Property_Names (I), To_String (Value));
         end case;
      end loop;
   end To_Dictionary;

   overriding procedure Render_Response
     (This : Jintp_Renderer;
      View : String;
      Model : Meadowsweet.Inspectable_Bean'Class;
      Response : in out Servlet.Responses.Response'Class)
   is
      Stream : Servlet.Streams.Print_Stream := Response.Get_Output_Stream;
      Content : Unbounded_String;
      Values : Standard.Jintp.Dictionary;
   begin
      To_Dictionary (Model, Values);
      Content := Standard.Jintp.Render (View, Values);
      Response.Set_Content_Length (Length (Content));
      Stream.Write (Content);
   end Render_Response;

end Meadowsweet.Jintp;
