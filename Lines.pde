class Lines {

    HashMap<Integer, Line> lines = new HashMap<Integer, Line>();

    Lines() {}


    createLineAt(
        int identity,
        int x, 
        int y
    ) {
        Line line = new Line( identity );
        PVector p = new PVector(x, y);
        line.add(p);
        this.lines.put(this.lines.size(), line);
    }

    getLine(
        int identity
    ) {
        return this.lines.get(identity);
    }

    updateLine(
        int identity,
        int x, 
        int y
    ) {
        Line line = this.lines.get(identity);

        if ( line ) {
            PVector p = new PVector(x, y);
            line.add(p);
        }

    }

    endLine(
        int identity
    ) {
        Line line = this.lines.get( identity );

        if ( line ) {
            line.draw();
        }

    }

}