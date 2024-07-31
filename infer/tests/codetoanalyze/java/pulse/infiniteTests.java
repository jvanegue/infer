public abstract class Tests {
    
    // 
    void empty_function_terminate() {
        return;
    }
  
    // 
    void one_liner_terminate(int x) {
        x++;
    }
  
  
    // 
    void two_liner_terminate(int x) {
        x++;
        return;
    }
    
    /* pulse-inf:  */
    void simple_loop_terminate() {
        int y = 0;
        while (y < 100) {
            y++;
        }
    }
    
    /* pulse-inf:  */
    abstract void fcall(int y);
    
    void loop_call_not_terminate(int y) {
        while (y == 100) {
            fcall(y);
        }
        return;
    }
    
    /* pulse-inf:  */
    void loop_pointer_terminate(int x, int y) {
        if (x != y) {
            while (y < 100) {
                y++;
                x--;
            }
        }
    }
    
    /* pulse-inf:  */
    void loop_pointer_non_terminate(int x, int y) {
        if (x == y){
            while (y < 100) {
                y++;
                y = x;
            }   
        }
    }
    
    /* pulse-inf:  */
    void loop_conditional_not_terminate(int y) {
        int x = 0;
        while (y < 100) {
            if (y < 50) {
                x++;
            } else {
                y++;
            }
        }
    }
    
    
    
    /* pulse-inf:  */
    void nested_loop_cond_not_terminate(int y) {
        int x = 42;
        while (y < 100) {
            while (x <= 100) {
                if (x == 10) {
                    x = 1;
                } else {
                    x++;
                }
            }
        y++;
        }
    }
    
    
    /* pulse-inf:  */
    /* NEW FALSE NEG??? */
    void simple_loop_not_terminate(int y) {
        int x = 1;
        while (x != 3) {
            y++;
        }
    }
    
    
    
    /* pulse-inf:  */
    void loop_alternating_not_terminate(int y, int x) {
        boolean turn = false;
        while (x < 100) {
            if (turn){
                x++;
            } else { 
                x--;
            }
        turn = (turn ? false : true);
        }
    }
    
    
    /* pulse-inf:  */
    void nested_loop_not_terminate(int y, int x) {
        
        while (y < 100) {
            while (x <= 100) {
                if (x == 10) {
                    x = 1;
                } else {
                    x++;
                }
            }
            y++;
        }
    }
    
    
    /* pulse-inf:  */
    void inner_loop_non_terminate(int y, int x) {
        while (y < 100) {
            while (x == 0) {
                y++;
            }
            y++;
        }
    }
    
    
    /* pulse-inf:  */
    void simple_dowhile_terminate(int y, int x) {
        do {
            y++;
            x++;
        } while (false);
    }

    
    /* pulse-inf:  */
    void loop_signedarith_terminate(int y) {
        while (y > 0x7fffffff) {
            y++;
            y--;
        }
        return;
    }
    
    
    /* pulse-inf:  */
    void loop_with_break_terminate(int y) {
        y = 0;
        while (y < 100) {
            if (y == 50) {
                break;
            } else {
                y++;
            }
        }
    }
    
    /* pulse-inf: */
    void loop_with_break_terminate_var1(int y) {
        y = 0;
        while (y < 100){
            if (y == 50) {
                y--;
                break;
            } else {
                y++;
            }
        }
    }
    
    /* pulse-inf:  */
    void loop_with_break_terminate_var2(int y) {
        while (y < 100) {
            if (y == 50) {
                y--;
                break;
            } else {
                y++;
            }
        }
    }
    
    /* pulse-inf:  */
    void loop_with_break_terminate_var3(int y) {
        while (y < 100) {
            if (y == 50)
                break;
            else
                y++;
        }
    }
    
    /* pulse-inf:  */
    void loop_with_return_terminate(int y) {
        while (y < 100)
            if (y == 50) {
                y--;
                return;
             } else
                y++;
    }
    
    /* pulse-inf:  */
    void loop_with_return_terminate_var1(int y) {
        while (y < 100)
            if (y == 50)
                return;
            else
                y++;
    }
    
    
    /* pulse-inf: */
    void loop_with_return_terminate_var2(int y) {
        y = 0;
        while (y < 100)
            if (y == 50) {
                y--;
                return;
            } else
                y++;
    }
    
    /* pulse-inf:  */
    void loop_with_return_terminate_var3(int y) {
        y = 0;
        while (y < 100)
            if (y == 50)
                return;
            else
                y++;
    }
    
    /* pulse-inf:  */
    // From: Gupta POPL 2008 - "Proving non-termination"
    int bsearch_non_terminate_gupta08(int a[], int k,
                        int lo,
                        int hi) {
        int mid;
        
        while (lo < hi) {
            mid = (lo + hi) / 2;
            if (a[mid] < k) {
                lo = mid + 1;
            } else if (a[mid] > k) {
                hi = mid - 1;
            } else {
                return mid;
            }
        }
        return -1;
    }
    
    
    /* pulseinf:  */
    // Cook et al. 2006 - TERMINATOR fails to prove termination
    /*
    typedef struct  s_list{
        int	value;
        struct s_list *next;
    }		list_t;
    */
    /* pulse-inf: works good, no bug */
    /* 
    static void list_iter_terminate_cook06(list_t *p) {
        int tot = 0;
        do {
            tot += p->value;
            p = p->next;
        }
        while (p != 0);
    }
        */
    
    /* pulse-inf: works good, no bug */
    /*
    static void
    list_iter_terminate_cook06_variant(list_t *p) {
        int tot = 0;
            while (p != 0) {
            tot += p->value;
            p = p->next;
        }
    } */
    
    /* pulse-inf:  */
    /* 
    static void
    list_iter_terminate_cook06_variant2(list_t *p) {
        int tot;
        for (tot = 0; p != 0; p = p->next) {
            tot += p->value;
        }
    } 
    */
    
    /* pulse-inf:  */
    // Cook et al. 2006 - TERMINATOR proves termination
    void two_ints_loop_terminate_cook06(int x, int y) {
        if (y >= 1) 
            while (x >= 0)
                x = x + y;
    }
    
    
    
    /* Cook et al. 2006 - Prove termination with non-determinism involved */
    int Ack(int x, int y)
    {
        if (x>0) {
        int n;
        if (y>0) {
            y--;
            n = Ack(x,y);
        } else {
            n = 1;
        }
        x--;
        return Ack(x,n);
        } else {
        return y+1;
        }
    }

    
    /* pulse-inf:  */
    /* 
    int nondet() { return (rand()); }
    int benchmark_terminate_nondet_cook06()
    {
        int x = nondet();
        int y = nondet();
    
        int * p = &y;
        int * q = &x;
        bool b = true;
        
        while (x<100 && 100<y && b)
        {
            if (p==q) {
                int k = Ack(nondet(),nondet());
                (*p)++;
                while((k--)>100) {
                    if (nondet()) {p = &y;}
                    if (nondet()) {p = &x;}
                    if (!b) {k++;}
                }
            } else {
        (*q)--;
        (*p)--;
        if (nondet()) {p = &y;}
        if (nondet()) {p = &x;}
            }
            b = nondet();
        }
        return (0);
    } */
    
    
    /* pulseinf:  */
    // Cook et al. 2006 - termination with non determinism 
    //#include <stdlib.h>
    int nondet() { 
        return ((int)(Math.random() * Integer.MAX_VALUE)); 
    }

    boolean nondetBool() {
        return (Math.random() < 0.5);
    }

    int npc = 0;
    int nx, ny, nz;
    void benchmark_terminate_cook06()
    {
        int x = nondet(), y = nondet(), z = nondet();
        if (y>0) {
        do {
            if (npc == 5) {
        if (!( (y < z && z <= nz)
                || (x < y && x >= nx)
                || false))
            ;
            }
            if (npc == 0) {
        if (nondetBool()) {
            nx = x;
            ny = y;
            nz = z;
            npc = 5;
        }
            }
            if (nondetBool()) {
        x = x + y;
            } else {
        z = x - y;
            }
        } while (x < y && y < z);
        }
    }
    
    
    /* pulseinf:  */
    // Cook et al. 2006 proves termination with non determinism 

    void benchmark_simple_terminate_cook06() {
        int x = nondet(), y = nondet(), z=nondet();
        if (y > 0) {
            do {
                if (nondetBool()) {
                    x = x + y;
                } else {
                    z = x - y;
                }
            } while (x < y && y < z);
        }
    }
    
    
    
    /* Simple non-det benchmark for non-terminate */
    /* Inspired by cook'06 by flipping existing test benchmark_simple_terminate_cook06 */
    /* pulse-inf:  */
    void	nondet_loop_non_terminate(int z)
    {
        int x = 1;
        while (x < z)
        if (nondetBool())
            x++;
    }
    
    
    /* From: AProVE: Non-termination proving for C Programs (Hensel et al. TACAS 2022)*/
    /* pulse-inf:  */
    void hensel_tacas22_non_terminate(int x, int y)
    {
        y = 0;
        while (x > 0)
        {
            x--;
            y++;
        }
        while (y > 1)
        y = y;
    }
    
    
    /* Harris et al. "Alternation for Termination (SAS 2010) - Terminating program */
    void	foo(int x) {
        x--;
    }
    
    /* Pulse-inf:  */
    void interproc_terminating_harris10(int x) {
        while (x > 0)
            foo(x);
    }
    
    /* Derived from Harris'10 - Pulse-inf: FP! */
    void interproc_terminating_harris10_cond(int x) {
        while (x > 0) {
            if (nondetBool()) foo(x);
            else foo(x);
        }
    }
    
    
    /* Harris et al. "Alternation for Termination (SAS 2010) - Non Terminating program */
    /* TERMINATOR unable to find bug */
    /* TREX find bug in 5sec */
    /* pulse-inf:  */
    void loop_non_terminating_harris10(int x, int d, int z)
    {
        d = 0;
        z = 0;
        while (x > 0) {
            z++;
            x = x - d;
        }
    }
    
        
    /*** Chen et al. TACAS 2014 */
    // TNT proves non-termination with non determinism
    /* Pulse-inf:  */
    /* TO me: there is no bug here! problem in chen14 paper - the nondet() should eventually make it break */

    void nondet_nonterminate_chen14(int k, int i) {
        if (k >= 0)
        ;
        else
            i = -1;
        while (i >= 0)
            i = nondet();
        i = 2;
    }
    
    // TNT fails to prove non-termination
    /* pulse-inf: */
    /* To me: this will terminate because k >= 0 will eventually be false due to integer wrap */
    void nestedloop2_nonterminate_chen14(int k, int j) {
        while (k >= 0) {
            k++;
            j = k;
            while (j >= 1)
                j--;
        }
    }
    
    
    /* pulse-inf: works good! finds bug */
    // TNT proves non-termination
    /* NEW FALSE NEG??? */
    void nestedloop_nonterminate_chen14(int i) {
        if (i == 10) {
            while (i > 0) {
                i = i - 1;
                while (i == 0)
                ;
            }
        }
    }
    
    
    /****** Tests that reflect present in cryptographic libraries ********/
    
    
    // Example with array - no manifest bug
    void array_iter_terminate(int[] array)
    {
        int i = 0;
        while (array[i] != 0) {
            array[i] = 42;
            i++;
        }
    }
    
    
    // Example with two arrays - no manifest bug
    void array2_iter_terminate(int[] array1, int[] array2)
    {
        int i = 0;
        while (array1[i] != 0) {
        array2[i] = 42;
        i++;
        }
    }
    
    // Example with array and non-termination
    /* Pulse-inf:  */
    void array_iter_nonterminate(int[] array, int len) {
        int i = 0;
        while (i < len) {
            array[i] = 42;
            if (i > 10)
                i = 0;
            i++;
        }
    }
    
    // Iterate over an array - no bug
    /* Pulse-Inf:  */
    void iterate_arraysize_terminate(int[] array)
    {
        int i = 0;
        while (i < (array.length)) {
            array[i] = i;
            i++;
        }  
    }
    
    // Iterate over an array using a bitmask to compute array value
    /* Pulse-Inf:  */
    void iterate_bitmask_terminate(int[] array, int len)
    {
        int i = 0;
        while (i < len) {
        array[i] = (i & (~7));
        i++;
        }  
    }
    
    // Iterate over an array using a bitmask to compute array index
    /* Pulse-Inf:  */
    void iterate_bitmask2_terminate(int[] array, int len)
    {
        int i = 0;
        int j = 0;
        while (i < len) {
            j = (i & (~7));
            array[j] = i;
            i++;
        }  
    }
    
    // Iterate over an array using a bitmask leading to a non-termination
    /* Pulse-inf:  */
    void iterate_bitmask_nonterminate(int[] array, int len)
    {
        int i = 0;
        while (i < len) {
            i = (i & (~7));
            array[i] = i;
            i++;
        }  
    }
    
    
    
    // Simple bitshift test - will terminate as i will eventually reach 0
    void bitshift_right_loop_terminate(int i)
    {
        while (i!=0)
        i = i >> 1;
    }
    
    
    // Simple bitshift test - will terminate as i will eventually reach 0
    void bitshift_left_loop_not_terminate(int i)
    {
        while (i!=0)
        i = i << 1;
    }
    
    /* To Test: This should terminate */
    void bitshift_loop_terminate(int i)
    {
        while ((i % 2)!=0)
        i = (i << 1);
    }
    
    
    // Iterate over an array using a bitshift to compute array index leading to a non-termination
    /* Pulse-inf: */
    void iterate_bitshift_nonterminate(int[] array)
    {
        int i = 1;
        while (i != 0)
        {
            array[i] = i;
            i = i << 1;
        }  
    }
    
    // Iterate over an array using a bitshift to compute array index
    /* Pulse-inf:  */
    void iterate_bitshift_terminate(int[] array, int len)
    {
        int i = 1;
        while (i < len) {
        array[i] = i;
        i = i << 1;
        }  
    }
    
    // Iterate over an array using a bitshift to compute array index
    /* Pulse-inf:  */
    void iterate_bitshift_terminate2(int[] array, int i)
    {
        while (i != 0) {
            array[i] = i;
            i = i >> 1;
        }  
    }
    
    // Integer test computing a condition that will never be true
    /* Pulse-Inf:  */
    void iterate_intoverflow_nonterminate(int len)
    {
        int i = 0xFFFFFFFF;
        while (i != 0)
        i -= 2;
    }
    
    
    // Iterate over an array using a modulo arithmetic leading to a bug
    /* Pulse-infinite:  */
    /* To verify: this should work even with low widen threshold */
    void iterate_modulus_nonterminate(int[] array, int len, int i)
    {
        //unsigned int i = 0;
        while (i < len) {
            i = i % 2;
            array[i] = i;
            i++;
        }  
    }
    
    
    /* From: zlib */
    /* Iterate computing a crc value - terminates no bug */
    /* Pulse-inf:  */

    private static final int N = 5;
    private static final int W = 8;
    
    
    void iterate_crc_terminate()
    {
        int k;
        long crc0 = 0xFFFFFFFF;
        /*
        unsigned long crc1 = 0, crc2 = 0, crc3 = 0, crc4 = 0, crc5 = 0;
        unsigned short word0 = 6, word1 = 1, word2 = 2, word3 = 3, word4 = 4, word5 = 5;
        */
        for (k = 1; k < W; k++) {
            crc0++;
            /*
            crc0 ^= crc_braid_table[k][(word0 >> (k << 3)) & 0xff];
            crc1 ^= crc_braid_table[k][(word1 >> (k << 3)) & 0xff];
            crc2 ^= crc_braid_table[k][(word2 >> (k << 3)) & 0xff];
            crc3 ^= crc_braid_table[k][(word3 >> (k << 3)) & 0xff];
            crc4 ^= crc_braid_table[k][(word4 >> (k << 3)) & 0xff];
            crc5 ^= crc_braid_table[k][(word5 >> (k << 3)) & 0xff];
            */
        }
    }
    
    /* From: libpng */
    /* Test from libpng with typedefs */
    /* Expected result: no bug */
    void	png_palette_terminate(int val)
    {
        int	num;
        int	i;
        int   p = 0;
        
        if (val == 0)
        num = 1;
        else
        num = 256;
    
        for (i = 0; i < num; i++)
        p += val;
        
    }
    
    /* Peter O'Hearn's test - not terminate */
    /* Pulse-Inf:   */
    void simple_loop_equal_notterminate()
    {
        int x = 42;
        while (x == x)
        x = x + 1;
    }
    
    
    /* Pulse-Inf: OK! Find bug */
    int compute_increment(int k) {
        return ((k % 2) != 0 ? 1 : 0);
    }
    
    void loop_fcall_add_inductive_nonterminate()
    {
        int i;
        int incr;
        for (i = 0; i < 10; i += incr)
        incr = compute_increment(i);
        
    }

    /* ********* tests added by Caroline ********* */


    void simple_trycatch (int x) {
        try {
            x++;
        } catch (Exception e) {
            System.out.println("Catch where there should be none.");
        }
    }

    void trycatch_loop_terminate1 (int x) {
        try { 
            while (x<12) { x++; } 
        } catch (Exception e) {
            System.out.println("Catch where there should be none.");
        }
    }

    void trycatch_loop_terminate2 (int x, int[] array) {
        try { 
            int len = array.length;
            array[len] = 12; 
        } catch (Exception e) {
            while (x<12) { x++; }
            System.out.println("Index oob.");
        }
    }

    void trycatch_loop_diverge (int x) {
        try { 
            while (x!=12) { x++; } 
        } catch (Exception e) {
            System.out.println("Catch where there should be none.");
        }
    }

    int simple_trycatch_finally (int x) {
        try {
            x++;
        } catch (Exception e) {
            System.out.println("Catch where there should be none.");
        } finally {
            x--;
        }
        return x;
    }

    void trycatch_finally_terminate (int x) {
        try {
            x++;
        } catch (Exception e) {
            System.out.println("Catch where there should be none.");
        } finally {
            while (x<12) { x++; }
        }
    }

    void trycatch_finally_diverge (int x) {
        try {
            x++;
        } catch (Exception e) {
            System.out.println("Catch where there should be none.");
        } finally {
            while (x!=12) { x++; }
        }
    }

    void trycatch_div0 (int x) {
        try {
            int z = 12/x;
        } catch (Exception e) {
            System.out.println("Div by zero.");
        }
    }

    void trycatch_div0_terminate (int x) {
        int y = 0;
        try {
            int z = 12/x;
        } catch (Exception e) {
            System.out.println("Div by zero.");
            if (x==0) { return; } else {
                while (y==0) { 
                    y++; 
                    x++; 
                    y--; 
                }
            }
        }
    }

    void trycatch_div0_diverge (int x) {
        int y = 0;
        try {
            int z = 12/x;
        } catch (Exception e) {
            System.out.println("Div by zero.");
            if (x!=0) { return; } else {
                while (y==0) { 
                    y++; 
                    x++; 
                    y--; }
            }
        }
    }

    void trycatch_trycatch_terminate (int x) {
        int y = 0;
        try {
            int z = 12/x;
        } catch (Exception e1) {
            try {
                int z = 12/(x-1);
            } catch (Exception e2) {
                while (x==0) { y++; }
            }
        }
    }

    void trycatch_trycatch_finally_terminate (int x) {
        int y = 0;
        try {
            y = 1;
            int z = 12/x;
        } catch (Exception e1) {
            try {
                y = 2;
                int z = 12/(x-1);
            } catch (Exception e2) {
                System.out.println("Div by zero.");
            }
        } finally { 
            while (y==0) { x++; }
        }
    }

    void trycatch_trycatch_finally_diverge (int x) {
        int y = 0;
        try {
            y = 1;
            int z = 12/x;
        } catch (Exception e1) {
            try {
                y = 2;
                int z = 12/(x-1);
            } catch (Exception e2) {
                System.out.println("Div by zero.");
            }
        } finally { 
            while (y!=0) { 
                y++; 
                x++; 
                y--; 
            }
        }
    }

    void loop_trycatch_terminate (int x) {
        x = Math.abs(x);
        int y = 0;
        while (x!=0) {
            try {
                y = 12/x;
                x--;
            } catch (Exception e) {
                while (x==0) { y++; }
            }
        }
    }

    void loop_trycatch_diverge (int x) {
        x = Math.abs(x);
        int y = 0;
        while (x!=0) {
            try {
                y = 12/x;
                x--;
            } catch (Exception e) {
                while (x==0) { y++; }
            }
        }
    }
}
