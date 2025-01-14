class Lines {

    HashMap<Integer, Line> lines = new HashMap<Integer, Line>();

    Lines() {}


    void createLineAt(
        int identity,
        int x, 
        int y
    ) {
        Line line = new Line( identity );
        PVector p = new PVector(x, y);
        line.add(p);
        this.lines.put(this.lines.size(), line);
    }

    Line getLine(
        int identity
    ) {
        return this.lines.get(identity);
    }

    void updateLine(
        int identity,
        int x, 
        int y
    ) {
        Line line = this.lines.get(identity);

        // if ( line !== null ) {
            PVector p = new PVector(x, y);
            line.add(p);
        // }

    }

    void endLine(
        int identity
    ) {
        Line line = this.lines.get( identity );

        // if ( line ) {
            line.draw();
        //}

    }

}